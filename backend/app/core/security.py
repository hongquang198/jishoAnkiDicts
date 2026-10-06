from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
import hashlib
import secrets
from jose import jwt
from app.core.config import settings

def issue_access_token(user_id: str, minutes: int | None = None) -> str:
    # minutes=None means "the configured lifetime": tests pass explicit
    # values (e.g. -1 for an already-dead token), production uses the env.
    lifetime = minutes if minutes is not None else settings.access_token_minutes
    exp = datetime.now(timezone.utc) + timedelta(minutes=lifetime)
    return jwt.encode({'sub': user_id, 'exp': exp}, settings.jwt_secret, algorithm=settings.jwt_alg)


def parse_user_id(token: str) -> str | None:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_alg])
        sub = payload.get('sub')
        return str(sub) if sub else None
    except Exception:
        return None

_pwd = CryptContext(schemes=['bcrypt'], deprecated='auto')

def hash_password(password: str) -> str:
    return _pwd.hash(password)


def hash_refresh_token(raw: str) -> str:
    # SHA-256, not bcrypt: refresh tokens are 256-bit random (brute force is
    # infeasible), and lookups hash-then-query — bcrypt's salt would break
    # that. Same reason session tokens conventionally use fast hashes.
    return hashlib.sha256(raw.encode()).hexdigest()


def new_refresh_token() -> tuple[str, str]:
    # Returns (raw, hash): raw travels to the client once, hash is stored.
    raw = secrets.token_urlsafe(48)
    return raw, hash_refresh_token(raw)


def verify_password(password: str, password_hash: str) -> bool:
    return _pwd.verify(password, password_hash)