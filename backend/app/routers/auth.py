import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.deps import get_current_user_id
from app.core.security import issue_access_token
from app.db.session import get_db
from app.models import db as models
from app.core.config import settings
import google.auth.transport.requests as google_requests
import google.oauth2.id_token as google_id_token

from app.models.schemas import AuthLinkGoogle

router = APIRouter(prefix='/auth', tags=['auth'])

@router.post('/anon', status_code=201)
def sign_in_anonymously(db: Session = Depends(get_db)) -> dict:
    user = models.User(id=f'anon_{uuid.uuid4().hex[:12]}', is_anonymous=True)
    db.add(user)
    db.commit()
    return {'user_id': user.id, 'access_token': issue_access_token(user.id)}

@router.get('/me')
def me(user_id: str = Depends(get_current_user_id)) -> dict:
    return {'user_id': user_id}

@router.post('/link-google')
def link_google(
    body: AuthLinkGoogle,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    if not settings.google_client_id:
        raise HTTPException(
            status.HTTP_501_NOT_IMPLEMENTED,
            'Google link not configured',
        )
    try:
        # Verifies signature + aud (our client id) + exp in one call.
        info = google_id_token.verify_oauth2_token(
            body.id_token, google_requests.Request(),
            settings.google_client_id,
        )
    except ValueError:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED, 
            'Invalid Google token',
        )
    google_sub = info['sub']
    clash = db.query(models.User).filter(
        models.User.google_sub == google_sub).first()
    if clash is not None and clash.id != user_id:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            'Google account already linked elsewhere')
    user = db.get(models.User, user_id)
    if user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            'User not found',
        )
    user.google_sub = google_sub
    user.is_anonymous = False
    db.commit()
    return {'user_id': user.id, 'access_token': issue_access_token(user.id)}