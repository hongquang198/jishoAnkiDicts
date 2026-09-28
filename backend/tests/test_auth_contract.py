from fastapi.testclient import TestClient

from app.main import create_app


def test_cards_require_auth():
    client = TestClient(create_app())
    res = client.put('/cards/bulk', json={'cards': []})
    assert res.status_code in (401, 403)


def test_invalid_token_rejected():
    client = TestClient(create_app())
    res = client.get('/cards', headers={'Authorization': 'Bearer bogus'})
    assert res.status_code in (401, 403)