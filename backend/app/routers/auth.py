import time
import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.deps import get_current_user_id
from app.core.security import (
    hash_refresh_token,
    issue_access_token,
    new_refresh_token,
)
from app.db.session import get_db
from app.models import db as models
from app.core.config import settings
import google.auth.transport.requests as google_requests
import google.oauth2.id_token as google_id_token

from app.models.schemas import AuthLinkGoogle, AuthRefreshIn

router = APIRouter(prefix='/auth', tags=['auth'])

# Server clock in epoch millis (matches the int-timestamp convention):
# refresh expiry is the first timestamp the server itself must mint.
def _now_ms() -> int:
    return int(time.time() * 1000)


def _mint_pair(db: Session, user_id: str, email: str | None = None) -> dict:
    # One login = one access token + one refresh row. The raw refresh value
    # leaves the server exactly once (here); everything after uses its hash.
    raw, digest = new_refresh_token()
    db.add(models.RefreshToken(
        id=uuid.uuid4().hex,
        user_id=user_id,
        token_hash=digest,
        expires_at=_now_ms() + settings.refresh_token_days * 86400_000,
        created_at=_now_ms(),
    ))
    db.commit()
    pair = {
        'user_id': user_id,
        'access_token': issue_access_token(user_id),
        'refresh_token': raw,
    }
    if email is not None:
        pair['email'] = email
    return pair


@router.post('/refresh')
def refresh_session(body: AuthRefreshIn, db: Session = Depends(get_db)) -> dict:
    row = db.query(models.RefreshToken).filter(
        models.RefreshToken.token_hash == hash_refresh_token(body.refresh_token)
    ).first()
    if row is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Invalid refresh token')
    if row.revoked:
        # Spent token replayed: possible theft — wipe the whole family so
        # neither the attacker's copy nor the legitimate child works.
        db.query(models.RefreshToken).filter(
            models.RefreshToken.user_id == row.user_id).delete()
        db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Refresh token reused')
    if row.expires_at <= _now_ms():
        db.delete(row)
        db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Refresh token expired')
    # Rotation: the presented token dies, its replacement lives. A stolen
    # parent is therefore useful exactly once — and using it burns the child.
    row.revoked = True
    db.commit()
    return _mint_pair(db, row.user_id)


@router.post('/anon', status_code=201)
def sign_in_anonymously(db: Session = Depends(get_db)) -> dict:
    user = models.User(id=f'anon_{uuid.uuid4().hex[:12]}', is_anonymous=True)
    db.add(user)
    db.commit()
    return _mint_pair(db, user.id)

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


def _token_pair(db: Session, user_id: str, email: str | None = None) -> dict:
    return _mint_pair(db, user_id, email)


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
    return _token_pair(db, user.id, user.email)


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
        return _token_pair(db, owner.id, owner.email)
    user = _attach_google(db, user_id, info['sub'], info.get('email'))
    return _token_pair(db, user.id, user.email)