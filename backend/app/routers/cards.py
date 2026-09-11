# FILE: app/routers/cards.py
# WHAT: PUT /cards/bulk (LWW upsert) · GET /cards?since= (pull) ·
#   DELETE /cards/{id} (hard delete; client tombstone blocks resurrection).
# WHY: HTTP form of UserDataRepositoryImpl's push/pull/delete; batch upsert
#   replaces Firestore batch.set(merge:true).
# TUTOR SESSION: 12 — see backend/plan/00-tutor-sessions.md.
"""Cards resource — replaces `users/{uid}/cards/{cardId}`.

Sync protocol (mirrors UserDataRepositoryImpl):
- PUT /cards/bulk = pushCards (upsert batch, last-write-wins by updated_at)
- GET /cards?since= = pullCardsUpdatedSince
- DELETE /cards/{id} = deleteCard (tombstone respected client-side)
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import BulkCards

router = APIRouter(prefix='/cards', tags=['cards'])


@router.put('/bulk')
def push_cards(
    body: BulkCards,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    for card in body.cards:
        row = db.get(models.Card, (user_id, card.id))
        data = card.model_dump()
        if row is None:
            db.add(models.Card(user_id=user_id, **data))
        elif card.updated_at >= (row.updated_at or 0):
            for key, value in data.items():
                setattr(row, key, value)
    db.commit()
    return {'synced': len(body.cards)}


@router.get('')
def pull_cards(
    since: int = Query(0, ge=0),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    rows = (
        db.query(models.Card)
        .filter(models.Card.user_id == user_id, models.Card.updated_at >= since)
        .order_by(models.Card.updated_at.desc())
        .all()
    )
    return {
        'cards': [
            {c: getattr(r, c) for c in (
                'id', 'word', 'slug', 'reading', 'is_common', 'tags', 'jlpt',
                'senses', 'localized_definition', 'gloss_lang', 'is_favorite',
                'srs_data', 'added_at', 'updated_at', 'deck',
                'ai_tutor_comment', 'ai_memory_tip',
            )}
            for r in rows
        ]
    }


@router.delete('/{card_id}')
def delete_card(
    card_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    row = db.get(models.Card, (user_id, card_id))
    if row is not None:
        db.delete(row)
        db.commit()
    return {'deleted': card_id}
