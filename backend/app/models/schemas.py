# FILE: app/models/schemas.py
# WHAT: Pydantic request/response contracts for every endpoint.
# WHY: Field names mirror Dart toMap() keys 1:1, so bad client JSON fails fast
#   with a 422 + clear message — Firestore silently accepted anything.
# TRY: POST bad JSON in /docs and read the 422 (that's validation working).
# TUTOR SESSION: 03 — see backend/plan/00-tutor-sessions.md.
"""Pydantic contracts — field names mirror Flutter `toMap()` keys 1:1.

This keeps the Flutter <-> backend diff trivial and makes the
Firestore -> SQL migration auditable key by key.
"""
from pydantic import BaseModel, Field


class WordCardIn(BaseModel):
    id: str
    word: str = ''
    slug: str = ''
    reading: str = ''
    is_common: int = 0
    tags: str = '[]'
    jlpt: str = '[]'
    senses: str = '[]'
    localized_definition: str = ''
    gloss_lang: str = ''
    is_favorite: int = 0
    srs_data: str | None = None
    added_at: int = 0
    updated_at: int = 0
    deck: str = 'default'
    ai_tutor_comment: str | None = None
    ai_memory_tip: str | None = None


class WordViewIn(BaseModel):
    word: str
    view_count: int = 1
    first_viewed_at: int = 0
    last_viewed_at: int = 0


class ReviewLogIn(BaseModel):
    id: str
    card_id: str = ''
    rating: str = 'good'
    duration_ms: int = 0
    reviewed_at: int = 0
    prev_interval_ms: int = 0
    new_interval_ms: int = 0
    prev_ease: float = 2.5
    new_ease: float = 2.5


class UserSettingsIn(BaseModel):
    llm_api_key: str = ''
    llm_model: str = 'gemini-2.0-flash'
    llm_custom_prompt: str = ''
    llm_enabled: int = 1
    llm_gen_ui_enabled: int = 1
    source_language: str = 'Tiếng Việt'
    target_language: str = 'Japanese'
    has_completed_language_setup: int = 0
    updated_at: int = 0


class BulkCards(BaseModel):
    cards: list[WordCardIn] = Field(default_factory=list)


class BulkViews(BaseModel):
    views: list[WordViewIn] = Field(default_factory=list)


class BulkLogs(BaseModel):
    logs: list[ReviewLogIn] = Field(default_factory=list)


class AuthSignup(BaseModel):
    email: str
    password: str = Field(min_length=8, max_length=128)


class AuthLinkGoogle(BaseModel):
    id_token: str
