# FILE: app/core/config.py
# WHAT: One Settings object loaded from env vars / .env file.
# WHY: 12-factor rule — secrets live in the environment, never in code.
# FIREBASE COUNTERPART: google-services.json + hardcoded keys (the magic box).
# TRY: change .env → behavior changes, code untouched.
# TUTOR SESSION: 07 — see backend/plan/00-tutor-sessions.md.
"""Central settings — 12-factor: env vars override defaults, no secrets in code."""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = 'sqlite:///./jisho.db'
    redis_url: str = 'redis://localhost:6379/0'
    jwt_secret: str = 'change-me-in-env'
    jwt_alg: str = 'HS256'
    access_token_minutes: int = 60
    refresh_token_days: int = 30
    google_client_id: str = ''
    cors_origins: list[str] = ['http://localhost:3000']


settings = Settings()
