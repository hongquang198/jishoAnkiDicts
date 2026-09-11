# FILE: app/routers/ai.py
# WHAT: POST /ai/explain — P1 returns 501 on purpose.
# WHY: P2 turns this into cache→quota→Gemini→cache: the server holds the API
#   key (never shipped to the app), caches by (word,lang,model), enforces
#   per-user quotas. Your portfolio piece — leave it stubbed until P2.
# TUTOR SESSION: P2 (after Session 14) — see backend/plan/04-p2-differentiator.md.
"""P2 AI proxy — moves Gemini calls off the client key.

Why this is the portfolio piece: caching by (word, lang, model),
per-user quotas, prompt versioning, cost control. P1 returns 501.
"""
from fastapi import APIRouter, Depends, HTTPException

from app.core.deps import get_current_user_id

router = APIRouter(prefix='/ai', tags=['ai'])


@router.post('/explain')
def explain(body: dict, user_id: str = Depends(get_current_user_id)) -> dict:
    _ = (body, user_id)
    raise HTTPException(501, 'P2: implement cache -> quota -> Gemini -> cache')
