"""Orphan tokens: valid JWT, unknown user row (e.g. minted by another env).

Regression test for the local-vs-cloud 500: pushing with a well-formed
identity the database never met must provision the parent row, not die on
the foreign key. Unique ghost id per run (persistent shared database).
"""
import uuid

from fastapi.testclient import TestClient

from app.core.security import issue_access_token
from app.main import create_app


def test_orphan_token_provisioned_on_push():
    client = TestClient(create_app())
    ghost_id = f'ghost_{uuid.uuid4().hex[:8]}'
    headers = {'Authorization': f'Bearer {issue_access_token(ghost_id)}'}
    res = client.put(
        '/views/bulk',
        json={'views': [{'word': 'w'}]},
        headers=headers,
    )
    assert res.status_code == 200
    assert client.get('/auth/me', headers=headers).json() == {
        'user_id': ghost_id
    }
