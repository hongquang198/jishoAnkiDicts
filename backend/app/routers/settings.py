# FILE: app/routers/settings.py
# WHAT: PUT /settings (upsert one row) · GET /settings (null when never saved).
# WHY: The settings/config single-doc pattern as SQL: one row per user_id.
#   Session-13 exercise — smallest router, good warm-up.
# TUTOR SESSION: 13 — see backend/plan/00-tutor-sessions.md.
"""Settings — replaces `users/{uid}/settings/config` single doc."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import UserSettingsIn

router = APIRouter(prefix='/settings', tags=['settings'])


@router.put('')
def push_settings(
    body: UserSettingsIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    row = db.get(models.UserSettings, user_id)
    if row is None:
        db.add(models.UserSettings(user_id=user_id, **body.model_dump()))
    else:
        for key, value in body.model_dump().items():
            setattr(row, key, value)
    db.commit()
    return {'saved': True}


@router.get('')
def pull_settings(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    row = db.get(models.UserSettings, user_id)
    if row is None:
        return {'settings': None}
    return {
        'settings': {
            c: getattr(row, c) for c in (
                'llm_api_key', 'llm_model', 'llm_custom_prompt', 'llm_enabled',
                'llm_gen_ui_enabled', 'source_language', 'target_language',
                'has_completed_language_setup', 'updated_at',
            )
        }
    }
