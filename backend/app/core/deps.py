# FILE: app/core/deps.py
# WHAT: get_current_user_id — reads the Bearer token on every protected route.
# WHY: FastAPI "dependency" = a guard that runs before your endpoint code.
# FIREBASE COUNTERPART: firestore.rules `request.auth.uid == userId`, as code.
#   Missing/bogus token → 401 here, enforced by tests/test_auth_contract.py.
# TUTOR SESSION: 06 — see backend/plan/00-tutor-sessions.md.
"""HTTP auth dependency — replaces firestore.rules `request.auth.uid == userId`."""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.security import parse_user_id

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
