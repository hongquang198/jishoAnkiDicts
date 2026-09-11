# FILE: app/routers/logs.py
# WHAT: PUT /logs/bulk (insert-if-absent) · GET /logs?since=.
# WHY: Review logs are append-only history — never updated, so no LWW needed;
#   duplicate ids are ignored (idempotent retry). Session-13 exercise.
# TUTOR SESSION: 13 — see backend/plan/00-tutor-sessions.md.
"""Review logs — replaces `users/{uid}/review_logs/{logId}` (append-only)."""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import BulkLogs

router = APIRouter(prefix='/logs', tags=['logs'])


@router.put('/bulk')
def push_logs(
    body: BulkLogs,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    for log in body.logs:
        if db.get(models.ReviewLog, (user_id, log.id)) is None:
            db.add(models.ReviewLog(user_id=user_id, **log.model_dump()))
    db.commit()
    return {'synced': len(body.logs)}


@router.get('')
def pull_logs(
    since: int | None = Query(None, ge=0),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    query = db.query(models.ReviewLog).filter(models.ReviewLog.user_id == user_id)
    if since is not None:
        query = query.filter(models.ReviewLog.reviewed_at >= since)
    rows = query.order_by(models.ReviewLog.reviewed_at.desc()).all()
    return {
        'logs': [
            {
                'id': r.id,
                'card_id': r.card_id,
                'rating': r.rating,
                'duration_ms': r.duration_ms,
                'reviewed_at': r.reviewed_at,
                'prev_interval_ms': r.prev_interval_ms,
                'new_interval_ms': r.new_interval_ms,
                'prev_ease': r.prev_ease,
                'new_ease': r.new_ease,
            }
            for r in rows
        ]
    }
