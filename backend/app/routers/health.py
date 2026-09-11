# FILE: app/routers/health.py
# WHAT: GET /health → {"status": "ok"}. No auth, no DB.
# WHY: First route you'll build (Session 01): proves routing + uvicorn work,
#   and later serves as the deploy liveness probe. Tested by test_health.py.
# TUTOR SESSION: 01 — see backend/plan/00-tutor-sessions.md.
from fastapi import APIRouter

router = APIRouter(tags=['health'])


@router.get('/health')
def health() -> dict:
    return {'status': 'ok'}
