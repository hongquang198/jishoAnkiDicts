"""Gateway contract tests: POST /ai/generate.

Key discipline: only the live round-trip needs a real Gemini key, so it
skips cleanly without one (CI). Everything else asserts guards + validation,
which are the actual contract.
"""
import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import create_app

HAS_KEY = bool(settings.gemini_api_key)


def _anon(client: TestClient) -> dict:
    token = client.post('/auth/anon').json()['access_token']
    return {'Authorization': f'Bearer {token}'}


def test_generate_requires_auth():
    client = TestClient(create_app())
    res = client.post('/ai/generate', json={'prompt': 'hi'})
    assert res.status_code in (401, 403)


def test_generate_rejects_missing_prompt():
    # Pydantic 422 fires before endpoint code — no key needed.
    client = TestClient(create_app())
    res = client.post(
        '/ai/generate', json={'model': 'gemini-3.5-flash-lite'},
        headers=_anon(client),
    )
    assert res.status_code == 422


@pytest.mark.skipif(not HAS_KEY, reason='needs GEMINI_API_KEY')
def test_generate_miss_then_hit():
    client = TestClient(create_app())
    headers = _anon(client)
    body = {
        'prompt': 'Reply with exactly: gateway-ok',
        'model': 'gemini-3.5-flash-lite',
    }
    first = client.post('/ai/generate', json=body, headers=headers)
    assert first.status_code == 200
    second = client.post('/ai/generate', json=body, headers=headers)
    assert second.status_code == 200
    assert second.json()['cached'] is True
    assert second.json()['answer'] == first.json()['answer']
