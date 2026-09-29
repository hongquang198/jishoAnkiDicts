"""S13 resource round-trips: views (max-wins), logs (append-only), settings.

Needs Postgres. Each test mints a fresh anon (isolated identity) and uses
unique ids per run — the suite shares one persistent database, so fixed
ids would collide with leftovers from previous runs (P2.4 lesson).
"""
import uuid

from fastapi.testclient import TestClient

from app.main import create_app


def _auth(client: TestClient) -> dict:
    token = client.post('/auth/anon').json()['access_token']
    return {'Authorization': f'Bearer {token}'}


def _uid(prefix: str) -> str:
    return f'{prefix}_{uuid.uuid4().hex[:8]}'


def test_views_max_wins():
    client = TestClient(create_app())
    headers = _auth(client)
    word = _uid('word')
    assert client.put(
        '/views/bulk',
        json={'views': [{'word': word, 'view_count': 3}]},
        headers=headers,
    ).status_code == 200
    # Lower re-push must not move the counter backwards.
    assert client.put(
        '/views/bulk',
        json={'views': [{'word': word, 'view_count': 1}]},
        headers=headers,
    ).status_code == 200
    views = client.get('/views', headers=headers).json()['views']
    match = [v for v in views if v['word'] == word]
    assert len(match) == 1 and match[0]['view_count'] == 3


def test_logs_append_only_and_idempotent():
    client = TestClient(create_app())
    headers = _auth(client)
    log_id = _uid('log')
    body = {'logs': [{'id': log_id, 'card_id': 'c1'}]}
    assert client.put('/logs/bulk', json=body, headers=headers).status_code == 200
    # Duplicate retry: ignored, not duplicated.
    assert client.put('/logs/bulk', json=body, headers=headers).status_code == 200
    logs = client.get('/logs?since=0', headers=headers).json()['logs']
    assert len([l for l in logs if l['id'] == log_id]) == 1


def test_settings_single_row_none_before_save():
    client = TestClient(create_app())
    headers = _auth(client)
    assert client.get('/settings', headers=headers).json() == {'settings': None}
    res = client.put(
        '/settings', json={'llm_model': 'test-model'}, headers=headers
    )
    assert res.status_code == 200
    saved = client.get('/settings', headers=headers).json()['settings']
    assert saved['llm_model'] == 'test-model'
