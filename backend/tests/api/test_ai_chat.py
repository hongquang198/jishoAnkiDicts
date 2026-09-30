"""POST /ai/chat: stateless turns, full transcript per call.

The server holds no session: history replays, only the last message is new.
Live turn needs a key (skipped in CI); guards don't.
"""
import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import create_app

HAS_KEY = bool(settings.gemini_api_key)


def _auth(client: TestClient) -> dict:
    token = client.post('/auth/anon').json()['access_token']
    return {'Authorization': f'Bearer {token}'}


def test_chat_requires_auth():
    client = TestClient(create_app())
    res = client.post('/ai/chat', json={'messages': []})
    assert res.status_code in (401, 403)


def test_chat_rejects_bad_roles():
    # Literal['user', 'model'] enforced by Pydantic before endpoint code.
    client = TestClient(create_app())
    res = client.post(
        '/ai/chat',
        json={'messages': [{'role': 'system', 'text': 'hi'}]},
        headers=_auth(client),
    )
    assert res.status_code == 422


@pytest.mark.skipif(not HAS_KEY, reason='needs GEMINI_API_KEY')
def test_chat_turn_answers():
    client = TestClient(create_app())
    res = client.post(
        '/ai/chat',
        json={
            'messages': [
                {'role': 'user', 'text': 'You answer with exactly: chat-ok'},
                {'role': 'model', 'text': 'chat-ok'},
                {'role': 'user', 'text': 'Repeat your last message exactly'},
            ],
            'model': 'gemini-3.5-flash-lite',
        },
        headers=_auth(client),
    )
    assert res.status_code == 200
    assert res.json()['answer'].strip() != ''
