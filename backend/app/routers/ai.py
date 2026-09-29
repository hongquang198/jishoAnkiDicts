import hashlib
import logging
from datetime import date

import google.generativeai as genai
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.cache import get_redis
from app.core.config import settings
from app.core.deps import get_current_user_id
from app.models.schemas import AiGenerateIn

log = logging.getLogger(__name__)
router = APIRouter(prefix='/ai', tags=['ai'])

DAILY_QUOTA = 300

# Current default model (verified live 2026-09; 2.x retired June 2026).
# Google retires models yearly — this constant is the single place to move.
DEFAULT_AI_MODEL = 'gemini-3.5-flash-lite'


def _generate(model_name: str, prompt: str) -> str:
    genai.configure(api_key=settings.gemini_api_key)
    return genai.GenerativeModel(model_name).generate_content(prompt).text

def _ensure_quota(user_id: str, cache) -> None:
    # Shared by both endpoints: one counter per user per day, expires alone.
    if cache is None:
        return
    try:
        key = f'quota:{user_id}:{date.today().isoformat()}'
        used = cache.incr(key)
        if used == 1:
            cache.expire(key, 86400)
        if used > DAILY_QUOTA:
            raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, 'Daily quota exceeded ({DAILY_QUOTA})', headers={'Retry-After': '3600'})
    except HTTPException:
        raise
    except Exception:
        log.warning('Quota check skipped (Redis down)', exc_info=True)

def _call_with_fallback(model_name: str, prompt: str) -> tuple[str, str]:
    # Returns (answer, model_used). Same retired-model safety as /explain
    try:
        return _generate(model_name, prompt), model_name
    except Exception as e:
        if '404' in str(e) and model_name != DEFAULT_AI_MODEL:
            log.warning(f'Model {model_name} retired, falling back to {DEFAULT_AI_MODEL}')
            try:
                return _generate(DEFAULT_AI_MODEL, prompt), DEFAULT_AI_MODEL
            except Exception as e2:
                log.warning('Gemini fallback call failed', exc_info=True)
                raise HTTPException(status.HTTP_502_BAD_GATEWAY, f'AI provider error: {e2}')
        log.warning('Gemini call failed', exc_info=True)
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, f'AI provider error: {e}')

@router.post('/generate')
def ai_generate(body: AiGenerateIn, user_id: str = Depends(get_current_user_id)) -> dict:
    if not settings.gemini_api_key:
        raise HTTPException(status.HTTP_501_NOT_IMPLEMENTED, 'Gemini API key not set')
    if not body.prompt.strip():
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, 'Empty prompt')
    cache = get_redis()
    key = 'aigen:' + hashlib.sha256(f'{body.model}:{body.prompt}'.encode()).hexdigest()[:32]
    if cache is not None:
        try:
            if (hit:= cache.get(key)) is not None:
                return {'answer': hit, 'cached': True, 'model': body.model}
        except Exception:
            pass
    _ensure_quota(user_id, cache)
    answer, model_used = _call_with_fallback(body.model, body.prompt)
    if cache is not None:
        try:
            cache.set(key, answer, ex=86400)
        except Exception:
            pass
    return {'answer': answer, 'cached': False, 'model': model_used}
