import hashlib
import logging
from datetime import date

import google.generativeai as genai
from fastapi import APIRouter, Depends, HTTPException, status
from google.ai import generativelanguage as glm
from app.core.cache import get_redis
from app.core.config import settings
from app.core.deps import get_current_user_id
from app.models.schemas import AiChatIn, AiGenerateIn

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


@router.post('/chat')
def ai_chat(body: AiChatIn, user_id: str = Depends(get_current_user_id)) -> dict:
    # Stateless turns: the client resends the transcript every call, so the
    # server holds no session. History replays, only the last message is new.
    # Deliberately uncached: identical transcripts across users are rare and
    # branchy conversations make hits a staleness risk.
    if not settings.gemini_api_key:
        raise HTTPException(status.HTTP_501_NOT_IMPLEMENTED, 'Gemini API key not set')
    if not body.messages or not body.messages[-1].text.strip():
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, 'Empty transcript')
    _ensure_quota(user_id, get_redis())
    history = [
        glm.Content(parts=[glm.Part(text=m.text)], role=m.role)
        for m in body.messages[:-1]
    ]
    last = body.messages[-1].text
    model_used = body.model
    try:
        genai.configure(api_key=settings.gemini_api_key)
        chat = genai.GenerativeModel(body.model).start_chat(history=history)
        answer = chat.send_message(last).text
    except Exception as e:
        if '404' in str(e) and body.model != DEFAULT_AI_MODEL:
            log.warning(f'Model {body.model} retired, falling back to {DEFAULT_AI_MODEL}')
            model_used = DEFAULT_AI_MODEL
            try:
                chat = genai.GenerativeModel(model_used).start_chat(history=history)
                answer = chat.send_message(last).text
            except Exception as e2:
                log.warning('Gemini chat fallback failed', exc_info=True)
                raise HTTPException(status.HTTP_502_BAD_GATEWAY, f'AI provider error: {e2}')
        else:
            log.warning('Gemini chat failed', exc_info=True)
            raise HTTPException(status.HTTP_502_BAD_GATEWAY, f'AI provider error: {e}')
    return {'answer': answer, 'model': model_used}
