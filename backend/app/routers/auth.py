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

def _verify_google(body: AuthLinkGoogle) -> dict:
    # Google-signed identity proof: signature + aud (our client id) + exp.
    # A forged token fails here — never trust client claims directly.
    if not settings.google_client_id:
        raise HTTPException(
            status.HTTP_501_NOT_IMPLEMENTED,
            'Google link not configured',
        )
    try:
        return google_id_token.verify_oauth2_token(
            body.id_token, google_requests.Request(),
            settings.google_client_id,
        )
    except ValueError:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            'Invalid Google token',
        )


def _token_pair(user_id: str, email: str | None = None) -> dict:
    pair = {'user_id': user_id, 'access_token': issue_access_token(user_id)}
    if email is not None:
        pair['email'] = email
    return pair


def _google_owner(db: Session, google_sub: str):
    return db.query(models.User).filter(
        models.User.google_sub == google_sub).first()


def _ensure_email_free(db: Session, email: str | None, exclude_id: str) -> None:
    if email is None:
        return
    owner = db.query(models.User).filter(models.User.email == email).first()
    if owner is not None and owner.id != exclude_id:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            'Email already linked elsewhere')


def _attach_google(
    db: Session, user_id: str, google_sub: str, email: str | None,
):
    user = db.get(models.User, user_id)
    if user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            'User not found',
        )
    user.google_sub = google_sub
    new_email = email or user.email
    _ensure_email_free(db, new_email, user_id)
    user.email = new_email
    user.is_anonymous = False
    db.commit()
    return user


@router.post('/link-google')
def link_google(
    body: AuthLinkGoogle,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    # Strict link: attaches Google identity to the CURRENT user only.
    # Taken elsewhere -> 409 (the dialog surfaces it as error text).
    info = _verify_google(body)
    google_sub = info['sub']
    clash = _google_owner(db, google_sub)
    if clash is not None and clash.id != user_id:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            'Google account already linked elsewhere')
    user = _attach_google(db, user_id, google_sub, info.get('email'))
    return _token_pair(user.id, user.email)


@router.post('/google')
def google_auth(
    body: AuthLinkGoogle,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    # Login-or-link (mirrors Firebase's credential-already-in-use fallback):
    # known Google identity -> adopt its owner (login, anon abandoned);
    # unknown -> attach to the current user (register, rows preserved).
    info = _verify_google(body)
    owner = _google_owner(db, info['sub'])
    if owner is not None:
        return _token_pair(owner.id, owner.email)
    user = _attach_google(db, user_id, info['sub'], info.get('email'))
    return _token_pair(user.id, user.email)