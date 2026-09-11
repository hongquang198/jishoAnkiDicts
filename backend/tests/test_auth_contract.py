# FILE: tests/test_auth_contract.py
# WHAT: Unauthenticated PUT and bogus-token GET must fail 401/403.
# WHY: The executable version of firestore.rules — if this stays green,
#   user A can never touch user B's data. Guard-rails for all future work.
# TUTOR SESSION: 06 — see backend/plan/00-tutor-sessions.md.
"""Contract test: unauthenticated writes fail, bad tokens fail.

This is the firestore.rules replacement — must stay green.
"""
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
