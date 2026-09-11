# FILE: app/routers/auth.py
# WHAT: POST /auth/anon|signup|login|link-email, GET /auth/me.
#   POST /auth/link-google is a 501 stub until P2 (Session: Google verify).
# WHY: Replaces Firebase Auth. anon→link-email mirrors linkWithCredential:
#   the anonymous row keeps its id, so synced cards survive the upgrade.
#   Every route returns the same shape: {user_id, access_token}.
# TUTOR SESSION: 10 — see backend/plan/00-tutor-sessions.md.
"""Auth endpoints — replaces Firebase Auth for the side-by-side prototype.

P1: anon + email signup/login/link. P2: Google id_token verify + refresh
rotation. Every endpoint returns the same shape: {user_id, access_token}.
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id
from app.core.security import hash_password, issue_access_token, verify_password
from app.db.session import get_db
from app.models import db as models
from app.models.schemas import AuthLinkGoogle, AuthSignup

router = APIRouter(prefix='/auth', tags=['auth'])


def _token_pair(user_id: str) -> dict:
    return {'user_id': user_id, 'access_token': issue_access_token(user_id)}


@router.post('/anon', status_code=201)
def sign_in_anonymously(db: Session = Depends(get_db)) -> dict:
    user = models.User(id=f'anon_{uuid.uuid4().hex[:12]}', is_anonymous=True)
    db.add(user)
    db.commit()
    return _token_pair(user.id)


@router.post('/signup', status_code=201)
def signup(body: AuthSignup, db: Session = Depends(get_db)) -> dict:
    if db.query(models.User).filter(models.User.email == body.email).first():
        raise HTTPException(status.HTTP_409_CONFLICT, 'Email already in use')
    user = models.User(
        id=f'u_{uuid.uuid4().hex[:12]}',
        email=body.email,
        password_hash=hash_password(body.password),
        is_anonymous=False,
    )
    db.add(user)
    db.commit()
    return _token_pair(user.id)


@router.post('/login')
def login(body: AuthSignup, db: Session = Depends(get_db)) -> dict:
    user = db.query(models.User).filter(models.User.email == body.email).first()
    if user is None or not user.password_hash:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Invalid credentials')
    if not verify_password(body.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Invalid credentials')
    return _token_pair(user.id)


@router.post('/link-email')
def link_email(
    body: AuthSignup,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    """Attach email+password to an anonymous account (Firebase linkWithCredential)."""
    user = db.get(models.User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, 'User not found')
    clash = db.query(models.User).filter(models.User.email == body.email).first()
    if clash is not None and clash.id != user.id:
        raise HTTPException(status.HTTP_409_CONFLICT, 'Email already in use')
    user.email = body.email
    user.password_hash = hash_password(body.password)
    user.is_anonymous = False
    db.commit()
    return _token_pair(user.id)


@router.post('/link-google')
def link_google(
    body: AuthLinkGoogle,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    """P2: verify body.id_token against Google JWKS, then link by google_sub."""
    raise HTTPException(status.HTTP_501_NOT_IMPLEMENTED, 'P2: verify id_token first')


@router.get('/me')
def me(user_id: str = Depends(get_current_user_id)) -> dict:
    return {'user_id': user_id}
