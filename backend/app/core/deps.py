from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.security import parse_user_id
from app.db.session import get_db
from app.models import db as models

_bearer = HTTPBearer(auto_error=False)

def get_current_user_id(
    creds: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> str:
    if creds is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Missing bearer token')
    user_id = parse_user_id(creds.credentials)
    if user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Invalid token')
    return user_id


def ensure_user_row(db: Session, user_id: str) -> str:
    # Just-in-time provisioning: a valid JWT names a user the database may
    # not know (e.g. token minted by another environment sharing the secret).
    # Creating the parent row here turns a 500 FK violation into a working
    # first call. Safe: sub values only ever come from our own minting.
    if db.get(models.User, user_id) is None:
        db.add(models.User(id=user_id, is_anonymous=True))
        db.commit()
    return user_id


def provision_current_user(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
) -> None:
    # Router-level guard (declared once per router, covers all its endpoints
    # present and future): authenticate, then ensure the parent row exists.
    ensure_user_row(db, user_id)