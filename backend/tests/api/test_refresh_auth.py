"""Refresh-token rotation: sessions survive access-token expiry.

Proves the minute-61 story end to end: an expired access token 401s, but
the stored refresh token mints a fresh pair. Rotation + reuse detection
included (a replayed parent kills the whole token family).

Needs Postgres (refresh_tokens table via `alembic upgrade head`).
"""
import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.core.security import issue_access_token
from app.main import create_app


def _anon(client: TestClient) -> dict:
    res = client.post('/auth/anon')
    assert res.status_code == 201
    return res.json()


def _bearer(token: str) -> dict:
    return {'Authorization': f'Bearer {token}'}


def _refresh(client: TestClient, refresh_token: str):
    return client.post('/auth/refresh', json={'refresh_token': refresh_token})


def test_anon_returns_refresh_token():
    body = _anon(TestClient(create_app()))
    assert set(body) == {'user_id', 'access_token', 'refresh_token'}


def test_expired_access_rejected_but_refresh_renews():
    client = TestClient(create_app())
    session = _anon(client)
    # The minute-61 token: honestly dead, server says so.
    dead = issue_access_token(session['user_id'], minutes=-1)
    assert client.get('/auth/me', headers=_bearer(dead)).status_code == 401
    # ...but the session survives: refresh mints a live pair, same user.
    res = _refresh(client, session['refresh_token'])
    assert res.status_code == 200
    pair = res.json()
    assert set(pair) == {'user_id', 'access_token', 'refresh_token'}
    assert pair['user_id'] == session['user_id']
    assert (
        client.get('/auth/me', headers=_bearer(pair['access_token'])).status_code
        == 200
    )


def test_refresh_rotates_spent_token_dies():
    client = TestClient(create_app())
    session = _anon(client)
    assert _refresh(client, session['refresh_token']).status_code == 200
    # Replaying the spent token is not a renewal — it's reuse.
    assert _refresh(client, session['refresh_token']).status_code == 401


def test_reuse_kills_the_token_family():
    client = TestClient(create_app())
    session = _anon(client)
    child = _refresh(client, session['refresh_token']).json()
    # Attacker replays the spent parent: family wiped, the child dies too.
    assert _refresh(client, session['refresh_token']).status_code == 401
    assert _refresh(client, child['refresh_token']).status_code == 401


def test_bogus_refresh_rejected():
    client = TestClient(create_app())
    assert _refresh(client, 'bogus').status_code == 401


def test_expired_refresh_rejected(monkeypatch: pytest.MonkeyPatch):
    # A negative lifetime mints an already-dead row: expiry is enforced.
    monkeypatch.setattr(settings, 'refresh_token_days', -1)
    client = TestClient(create_app())
    session = _anon(client)
    assert _refresh(client, session['refresh_token']).status_code == 401
