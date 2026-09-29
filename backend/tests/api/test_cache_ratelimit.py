"""P2.2 cache + rate limits, observed from outside the API.

Needs Postgres; cache assertions need Redis (skipped cleanly without it —
degraded mode is itself specified behavior). Rate-limit buckets are keyed
per fresh anon, so tests never spend each other's budget.
"""
import pytest
import redis
from fastapi.testclient import TestClient

from app.main import create_app


def _redis_or_none():
    try:
        client = redis.Redis(
            host='localhost', port=6379, decode_responses=True
        )
        client.ping()
        return client
    except Exception:
        return None


needs_redis = pytest.mark.skipif(
    _redis_or_none() is None,
    reason='needs local Redis (docker compose up -d redis)',
)


def _auth(client: TestClient) -> dict:
    token = client.post('/auth/anon').json()['access_token']
    return {'Authorization': f'Bearer {token}'}


@needs_redis
def test_cards_pull_caches_then_push_invalidates():
    client = TestClient(create_app())
    headers = _auth(client)
    store = _redis_or_none()
    assert store is not None

    # Set-difference: other tests share this Redis, so only our delta matters.
    before = set(store.keys('cards:*'))
    assert client.get('/cards?since=0', headers=headers).status_code == 200
    assert len(set(store.keys('cards:*')) - before) == 1
    # Second pull is served from cache (miss -> hit visible in key space).
    assert client.get('/cards?since=0', headers=headers).status_code == 200
    assert client.put('/cards/bulk', json={'cards': []}, headers=headers).status_code == 200
    assert set(store.keys('cards:*')) - before == set()


def test_bulk_push_rate_limited():
    client = TestClient(create_app())
    headers = _auth(client)
    codes = [
        client.put('/cards/bulk', json={'cards': []}, headers=headers).status_code
        for _ in range(35)
    ]
    assert 200 in codes and 429 in codes
