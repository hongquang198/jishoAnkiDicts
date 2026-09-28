import logging

import redis
from app.core.config import settings
# One client, built from env. decode_responses=True keeps everything str
# (no manual bytes juggling at call sites).

log = logging.getLogger(__name__)

_redis: redis.Redis | None = None


# Key namespaces, centralized: pull keys and invalidation scans must agree —
# a hand-typed 'cards:' in two places once caused stale-forever (P2.2 lesson).
def cards_key(user_id: str, since: int) -> str:
    return f'cards:{user_id}:{since}'


def cards_pattern(user_id: str) -> str:
    return f'cards:{user_id}:*'


def get_redis() -> redis.Redis | None:
    """Return the shared client, or None if Redis is unreachable.

    Cache must never break the API: callers fall back to Postgres on None.
    """
    global _redis
    if _redis is None:
        try:
            client = redis.Redis.from_url(settings.redis_url, decode_responses=True)
            client.ping()
            _redis = client
        except Exception:
            # A comment here would not run: log it, so silence is observable.
            log.warning('Redis unavailable, falling back to Postgres', exc_info=True)
            return None
    return _redis