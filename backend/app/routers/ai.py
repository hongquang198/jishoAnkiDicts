import hashlib
import logging
from datetime import date

import google.generativeai as genai
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.cache import get_redis
from app.core.config import settings
from app.core.deps import get_current_user_id
from app.models.schemas import AiExplainIn

log = logging.getLogger(__name__)
router = APIRouter(prefix='/ai', tags=['ai'])

DAILY_QUOTA = 300

# Current default model (verified live 2026-09; 2.x retired June 2026).
# Google retires models yearly — this constant is the single place to move.
DEFAULT_AI_MODEL = 'gemini-3.5-flash-lite'


def _generate(model_name: str, prompt: str) -> str:
    genai.configure(api_key=settings.gemini_api_key)
    return genai.GenerativeModel(model_name).generate_content(prompt).text

def _prompt(word: str, source_lang: str) -> str:
    # Server owns the prompt
    return (f'Explain the Japanese word "{word}" in {source_lang}:'
            'meaning, reading, one example sentence, and any usage note.'
            'Keep it concise.')

# TODO: Improve this because words have multiple forms. Need to confirm to dictionary form
def _cache_key(body: AiExplainIn) -> str:
    # Global key (no user_id): same question → same answer for everyone.
    # One user pays, all benefit — that's the caching economics.
    word_hash = hashlib.sha256(body.word.strip().encode()).hexdigest()[:16]
    return f'ai:{body.model}:{body.source_lang}:{word_hash}'

@router.post('/explain')
def ai_explain(body: AiExplainIn, user_id: str = Depends(get_current_user_id)) -> dict:
    if not settings.gemini_api_key:
        raise HTTPException(status.HTTP_501_NOT_IMPLEMENTED, 'Gemini API key not set')
    cache = get_redis()
    key = _cache_key(body)
    if cache is not None:
        try:
            if (hit := cache.get(key)) is not None:
                return {'word': body.word, 'answer': hit, 'cache': True, 'model': body.model}
        except Exception:
            pass   # corrupt entry behaves like a miss
    # Quota: one counter per user per day, expires on its own.
    if cache is not None:
        try:
            used = cache.incr(f'quota:{user_id}:{date.today().isoformat()}')
            if used == 1:
                cache.expire(f'quota:{user_id}:{date.today().isoformat()}', 86400)
            if used > DAILY_QUOTA:
                raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, 'Daily quota exceeded',
                                    headers = {'Retry-After': '3600'})
        except HTTPException:
            raise
        except Exception:
            log.warning('Quota check skipped (Redis down)', exc_info=True)
    model_used = body.model
    prompt = _prompt(body.word, body.source_lang)
    try:
        answer = _generate(body.model, prompt)
    except Exception as e:
        # Retired-model fallback: old clients still send last year's id.
        # The 404 is matched on message text — the SDK surfaces HTTP status
        # inside the message, not as a typed error.
        if '404' in str(e) and body.model != DEFAULT_AI_MODEL:
            log.warning(f'Model {body.model} retired, falling back to {DEFAULT_AI_MODEL}')
            model_used = DEFAULT_AI_MODEL
            try:
                answer = _generate(model_used, prompt)
            except Exception as e2:
                log.warning('Gemini fallback call failed', exc_info=True)
                raise HTTPException(status.HTTP_502_BAD_GATEWAY, f'AI provider error: {e2}')
        else:
            log.warning('Gemini call failed', exc_info=True)
            raise HTTPException(status.HTTP_502_BAD_GATEWAY, f'AI provider error: {e}')
    if cache is not None:
        try:
            cache.set(key, answer, ex=86400)
        except Exception:
            pass
    return {'word': body.word, 'answer': answer, 'cache': False, 'model': model_used}