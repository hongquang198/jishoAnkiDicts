import uuid
from fastapi.testclient import TestClient
from app.main import create_app

def test_sync_api():
    c = TestClient(create_app())
    t = c.post('/auth/anon').json()['access_token']
    h = {'Authorization': f'Bearer {t}'}
    t2 = c.post('/auth/anon').json()['access_token']
    h2 = {'Authorization': f'Bearer {t2}'}
    id1 = f'temp1{uuid.uuid4().hex[:6]}'
    id2 = f'temp2{uuid.uuid4().hex[:6]}'
    payload = {
    'cards': [
            { 'id': id1, 'word': 'temp1', 'updated_at': 123123123 },
            { 'id': id2, 'word': 'temp2', 'updated_at': 123123123 }
                ]
        }

    r = c.put('/cards/bulk', json=payload, headers=h)
    assert r.json()['synced'] == 2
    r = c.delete(f'/cards/{id1}', headers=h)
    assert r.json()['deleted'] == id1
    r = c.get('/cards', headers=h)
    assert len(r.json()['cards']) == 1
    r = c.get('/cards', headers=h2)
    assert len(r.json()['cards']) == 0
