from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import BulkLogs
from app.core.ratelimit import limiter

router = APIRouter(prefix='/logs', tags=['logs'])

@router.put('/bulk')
@limiter.limit(limit_value='30/minute')
def push_logs(
    request: Request,
    body: BulkLogs,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    # duplicates are ignored
    logged = []
    for log in body.logs:
        row = db.get(models.ReviewLog, (user_id, log.id))
        if row is None and log.id not in logged:
            db.add(models.ReviewLog(user_id=user_id, **log.model_dump()))
            logged.append(log.id)
    db.commit()
    return {'synced': len(body.logs)}

@router.get('')
def pull_logs(
    since: int = Query(0, ge=0),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    rows = (db.query(models.ReviewLog)
            .filter(models.ReviewLog.user_id == user_id,
                    models.ReviewLog.reviewed_at >= since)
                    .order_by(models.ReviewLog.reviewed_at.desc()).all())
    return {
        'logs': [
            {'id': r.id, 'card_id': r.card_id, 'rating': r.rating, 'reviewed_at': r.reviewed_at}
                for r in rows]}
