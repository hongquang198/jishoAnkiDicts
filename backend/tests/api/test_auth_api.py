"""S10/P2.1 auth endpoints: anon bootstrap, identity echo, Google-link guards.

Needs Postgres (users table). Proves the flow the phone relies on:
cold start mints identity, /me echoes it, strangers are rejected, and
the Google-link endpoint enforces its contract (real-token test stays
manual — it needs a genuine Google-signed token).
"""
from fastapi.testclient import TestClient

from app.main import create_app


def _anon(client: TestClient) -> dict:
    res = client.post('/auth/anon')
    assert res.status_code == 201
    body = res.json()
    assert set(body) == {'user_id', 'access_token', 'refresh_token'}
    return body


def test_anon_returns_identity_and_token():
    _anon(TestClient(create_app()))


def test_me_echoes_bearer_identity():
    client = TestClient(create_app())
    session = _anon(client)
    res = client.get(
        '/auth/me',
        headers={'Authorization': f'Bearer {session["access_token"]}'},
    )
    assert res.status_code == 200
    assert res.json() == {'user_id': session['user_id']}


def test_me_rejects_strangers():
    client = TestClient(create_app())
    assert client.get('/auth/me').status_code in (401, 403)
    res = client.get(
        '/auth/me', headers={'Authorization': 'Bearer bogus'}
    )
    assert res.status_code in (401, 403)


def test_link_google_rejects_forged_token():
    client = TestClient(create_app())
    session = _anon(client)
    res = client.post(
        '/auth/link-google',
        json={'id_token': 'bogus'},
        headers={'Authorization': f'Bearer {session["access_token"]}'},
    )
    # 501 = server not configured (no GOOGLE_CLIENT_ID); 401 = configured
    # and Google's keys rejected the forgery. Both are correct refusals.
    assert res.status_code in (401, 501)
