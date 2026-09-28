from fastapi import Request
from slowapi import Limiter
from slowapi.util import get_remote_address

def _key(request: Request) -> str:
    # Bucket by identity when known, by IP when not. Only the token tail is
    # used — full tokens must never land in logs or storage (S05 secret rule).
    auth = request.headers.get('authorization', '')
    if auth.startswith('Bearer ') and len(auth) > 20:
        return f'user:{auth[-12:]}'
    return f'ip:{get_remote_address(request)}'

# No default limits: each route opts in explicitly below (least surprise).
limiter = Limiter(key_func=_key)