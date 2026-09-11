# FILE: tests/test_health.py
# WHAT: Boots the app with TestClient (fake HTTP, no server) and hits /health.
# WHY: Session 02's concept — tests as spec: this file answers "does it start?"
#   Run: pytest (from backend/, after pip install -r requirements.txt).
# TUTOR SESSION: 02 — see backend/plan/00-tutor-sessions.md.
"""Smoke test: app boots and health answers. Run: pytest."""
from fastapi.testclient import TestClient

from app.main import create_app


def test_health_ok():
    client = TestClient(create_app())
    res = client.get('/health')
    assert res.status_code == 200
    assert res.json() == {'status': 'ok'}
