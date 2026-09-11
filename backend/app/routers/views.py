# FILE: app/routers/views.py
# WHAT: PUT /views/bulk (higher view_count wins) · GET /views (all).
# WHY: Same push/pull shape as cards, but max-wins instead of LWW —
#   counters only move up, so "newer" is meaningless. Your Session-13
#   repetition exercise (80% solo).
# TUTOR SESSION: 13 — see backend/plan/00-tutor-sessions.md.
"""Views resource — replaces `users/{uid}/views/{word}` (max-wins on view_count)."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import BulkViews

router = APIRouter(prefix='/views', tags=['views'])


@router.put('/bulk')
def push_views(
    body: BulkViews,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    for view in body.views:
        row = db.get(models.WordView, (user_id, view.word))
        if row is None:
            db.add(models.WordView(user_id=user_id, **view.model_dump()))
        elif view.view_count > (row.view_count or 0):
            row.view_count = view.view_count
            row.first_viewed_at = view.first_viewed_at
            row.last_viewed_at = view.last_viewed_at
    db.commit()
    return {'synced': len(body.views)}


@router.get('')
def pull_views(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    rows = db.query(models.WordView).filter(models.WordView.user_id == user_id).all()
    return {
        'views': [
            {
                'word': r.word,
                'view_count': r.view_count,
                'first_viewed_at': r.first_viewed_at,
                'last_viewed_at': r.last_viewed_at,
            }
            for r in rows
        ]
    }
