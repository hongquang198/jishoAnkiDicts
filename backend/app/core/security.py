# FILE: app/core/security.py
# WHAT: hash_password / verify_password / issue_access_token / parse_user_id.
# WHY: Two auth primitives in one place — (1) bcrypt so passwords are never
#   stored, (2) JWT (signed JSON with sub+exp) so the server stays stateless.
# FIREBASE COUNTERPART: Firebase ID tokens. HS256 is fine for one API;
#   move to RS256 only when several services must verify tokens.
# TRY: decode your token at jwt.io and watch it expire.
# TUTOR SESSIONS: 04 (hashing) + 05 (tokens).
"""Auth primitives: password hashing + JWT issue/verify.

P1 learns: never store plaintext, short-lived access tokens, HS256 is
fine for a single API (move to RS256 only when multiple services verify).
"""
from datetime import datetime, timedelta, timezone

from jose import jwt
from passlib.context import CryptContext

from app.core.config import settings

_pwd = CryptContext(schemes=['bcrypt'], deprecated='auto')


def hash_password(password: str) -> str:
    return _pwd.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    return _pwd.verify(password, password_hash)


def issue_access_token(user_id: str) -> str:
    exp = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_minutes
    )
    return jwt.encode(
        {'sub': user_id, 'exp': exp}, settings.jwt_secret, algorithm=settings.jwt_alg
    )


def parse_user_id(token: str) -> str | None:
    try:
        payload = jwt.decode(
            token, settings.jwt_secret, algorithms=[settings.jwt_alg]
        )
        sub = payload.get('sub')
        return str(sub) if sub else None
    except Exception:
        return None
