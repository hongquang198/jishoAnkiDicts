from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id, provision_current_user
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import UserSettingsIn

router = APIRouter(
    prefix='/settings',
    tags=['settings'],
    dependencies=[Depends(provision_current_user)],
)

@router.put('')
def push_settings(body: UserSettingsIn,
              user_id: str = Depends(get_current_user_id),
               db: Session = Depends(get_db)) -> dict:
    row = db.get(models.UserSettings, user_id)
    if row is None:
        db.add(models.UserSettings(user_id=user_id, **body.model_dump()))
    else:
        for key, value in body.model_dump().items():
            setattr(row, key, value)
    db.commit()
    return {'synced': 1}

@router.get('')
def pull_settings(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    row = db.get(models.UserSettings, user_id)
    if row is None:
        return {'settings': None}
    # Doesn't sqlachelmy has a model_dump() function? we'd have to manually type like this?
    return {'settings': {
        'llm_api_key': row.llm_api_key,
        'llm_model': row.llm_model,
        'llm_custom_prompt': row.llm_custom_prompt,
        'llm_enabled': row.llm_enabled,
        'llm_gen_ui_enabled': row.llm_gen_ui_enabled,
        'source_language': row.source_language,
        'target_language': row.target_language,
        'has_completed_language_setup': row.has_completed_language_setup,
        'updated_at': row.updated_at
    }}