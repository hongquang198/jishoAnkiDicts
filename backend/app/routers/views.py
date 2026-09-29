from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import BulkViews
from app.core.ratelimit import limiter

router = APIRouter(prefix='/views', tags=['views'])

@router.put('/bulk')
@limiter.limit(limit_value='30/minute')
def push_views(
    request: Request,
    body: BulkViews,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    for view in body.views:
        row = db.get(models.WordView, (user_id, view.word))
        if row is None:
            db.add(models.WordView(user_id=user_id, **view.model_dump()))
        elif view.view_count > (row.view_count or 0):
            for key, value in view.model_dump().items():
                setattr(row, key, value)
    db.commit()
    return {'synced': len(body.views)}

@router.get('')
def pull_views(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)) -> dict:
    rows = (db.query(models.WordView)
            .filter(models.WordView.user_id == user_id)
            .order_by(models.WordView.last_viewed_at.desc()).all())
    return {
        'views': [
            {'word': r.word,
             'view_count': r.view_count,
             'first_viewed_at': r.first_viewed_at,
             'last_viewed_at': r.last_viewed_at}
                for r in rows]}