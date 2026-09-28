from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.orm import Session
from app.core.deps import get_current_user_id
from app.core.cache import cards_key, cards_pattern, get_redis
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import BulkCards
from app.core.ratelimit import limiter
import json

router = APIRouter(prefix='/cards', tags=['cards'])

@router.put('/bulk')
@limiter.limit(limit_value='30/minute')
def push_cards(
    request: Request,
    body: BulkCards,  # Pydantic-validated JSON; bad shapes never reach this code (422 first)
    user_id: str = Depends(get_current_user_id),  # guard: resolves identity or raises 401
    db: Session = Depends(get_db)) -> dict:  # fresh session per request, auto-closed after
    if (cache := get_redis()) is not None:
        try:
            for key in cache.scan_iter(cards_pattern(user_id)):
                cache.delete(key)
        except Exception:
            pass
    
    for card in body.cards:
        # Composite-PK lookup: (user_id, card.id) — ownership enforced by the key itself.
        row = db.get(models.Card, (user_id, card.id))
        if row is None:
            # model_dump() = Pydantic object -> dict, unpacked into the ORM constructor.
            db.add(models.Card(user_id=user_id, **card.model_dump()))
        elif card.updated_at >= (row.updated_at or 0):
            # LWW: overwrite field-by-field only when remote is newer-or-equal.
            for key, value in card.model_dump().items():
                setattr(row, key, value)
    db.commit()  # one transaction for the whole batch: all-or-nothing.
    return {'synced': len(body.cards)}

@router.get('')
def pull_cards(
    # Query(0, ge=0) = validated query param: defaults to 0, negatives become 422.
    since: int = Query(0, ge=0),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    cache_key = cards_key(user_id, since)
    cache = get_redis()
    if cache is not None:
        try:
            if (hit := cache.get(cache_key)) is not None:
                return json.loads(hit)
        except Exception:
            pass    # corrupt entry behaves like a miss
                    # ... existing query builds `payload = {'cards': [...]}` ...
    rows = (db.query(models.Card)
            .filter(models.Card.user_id == user_id,
                    models.Card.updated_at >= since)
            .order_by(models.Card.updated_at.desc()).all())
    payload = {
        'cards': [
            {'id': r.id, 'word': r.word, 'updated_at': r.updated_at}
                for r in rows]
    }
    if cache is not None:
        try:
            cache.set(cache_key, json.dumps(payload), ex=120)
        except Exception:
            pass    # cache write failure must not fail the request
    return payload

@router.delete('/{card_id}')
def delete_card(
    card_id: str,  # path param: /cards/abc puts 'abc' here (routing, S01).
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    # Missing row is not an error: deletes must be idempotent (safe to retry).
    row = db.get(models.Card, (user_id, card_id))
    if row is not None:
        db.delete(row)
        db.commit()
    return {'deleted': card_id}