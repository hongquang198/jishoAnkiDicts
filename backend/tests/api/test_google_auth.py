"""POST /auth/google login-or-link, with Google's verification mocked.

verify_oauth2_token is the trust boundary (P2.1): everything past it is
our logic, fully testable with a forged-but-plausible payload. The final
test simulates a reinstall: fresh anon + same Google account -> same owner,
rows preserved.
"""
import uuid
from unittest.mock import patch

from fastapi.testclient import TestClient

import app.routers.auth as auth_router
from app.core.config import settings
from app.main import create_app


def _fake_info() -> dict:
    # Unique sub AND email per test: the suite shares one persistent
    # database, and reused identities turn fresh links into correct 409s
    # (google_sub) or UniqueViolations (email).
    tag = uuid.uuid4().hex[:8]
    return {'sub': f'google_test_{tag}', 'email': f't_{tag}@example.com'}


def _anon(client: TestClient) -> dict:
    body = client.post('/auth/anon').json()
    return {'Authorization': f'Bearer {body["access_token"]}'}


def _uid(prefix: str) -> str:
    return f'{prefix}_{uuid.uuid4().hex[:8]}'


def test_google_forgery_rejected_without_mock():
    client = TestClient(create_app())
    res = client.post(
        '/auth/google', json={'id_token': 'bogus'}, headers=_anon(client)
    )
    assert res.status_code in (401, 501)


def test_google_register_then_reinstall_adopts_owner(monkeypatch):
    # Hermetic: the id only needs to be non-empty — verification itself is
    # mocked, so CI (no GOOGLE_CLIENT_ID) behaves like local (configured).
    monkeypatch.setattr(settings, 'google_client_id', 'test-client-id')
    verify_path = 'app.routers.auth.google_id_token.verify_oauth2_token'
    with patch(verify_path, return_value=_fake_info()):
        client = TestClient(create_app())
        headers_a = _anon(client)
        first = client.post(
            '/auth/google', json={'id_token': 'mocked-ok'},
            headers=headers_a,
        )
        assert first.status_code == 200
        owner_a = first.json()['user_id']

        # Owner pushes a card, then "reinstalls" (fresh anon, same Google).
        card_id = _uid('gcard')
        assert client.put(
            '/cards/bulk',
            json={'cards': [{'id': card_id, 'word': 'w'}]},
            headers=headers_a,
        ).status_code == 200

        headers_b = _anon(client)
        second = client.post(
            '/auth/google', json={'id_token': 'mocked-ok'},
            headers=headers_b,
        )
        assert second.status_code == 200
        assert second.json()['user_id'] == owner_a

        # CRITICAL: adoption mints a NEW token for the owner. The pre-login
        # anon token still names the abandoned id — clients must replace
        # their stored token (RestAuthDataSource._saveSession does this).
        headers_owner = {
            'Authorization': f'Bearer {second.json()["access_token"]}'
        }

        # The adopted session sees the owner's rows: reinstall loses nothing.
        cards = client.get('/cards?since=0', headers=headers_owner).json()['cards']
        assert any(c['id'] == card_id for c in cards)


def test_link_google_strict_conflict(monkeypatch):
    monkeypatch.setattr(settings, 'google_client_id', 'test-client-id')
    verify_path = 'app.routers.auth.google_id_token.verify_oauth2_token'
    with patch(verify_path, return_value=_fake_info()):
        client = TestClient(create_app())
        headers_a = _anon(client)
        assert client.post(
            '/auth/link-google', json={'id_token': 'x'}, headers=headers_a
        ).status_code == 200
        # A different user linking the same Google identity -> 409.
        headers_b = _anon(client)
        res = client.post(
            '/auth/link-google', json={'id_token': 'x'}, headers=headers_b
        )
        assert res.status_code == 409