# FILE: app/main.py
# WHAT: App factory — creates the FastAPI app, enables CORS, registers routers.
# WHY: Kept thin on purpose: wiring only, zero business logic (SRP).
# FLUTTER COUNTERPART: lib/injection.dart (your GetIt wiring does the same job).
# RUN: uvicorn app.main:app --reload --port 8000 → docs at /docs.
# TUTOR SESSION: 01 — see backend/plan/00-tutor-sessions.md.
"""JishoAnki custom backend — FastAPI app factory.

Keep this file thin: wiring only. Business logic lives in
routers/* (HTTP) and services/* (pure domain logic).
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routers import auth, cards, views, logs, settings as settings_router
from app.routers import ai, health


def create_app() -> FastAPI:
    app = FastAPI(title='JishoAnki API', version='0.1.0')
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=['*'],
        allow_headers=['*'],
    )
    app.include_router(health.router)
    app.include_router(auth.router)
    app.include_router(cards.router)
    app.include_router(views.router)
    app.include_router(logs.router)
    app.include_router(settings_router.router)
    app.include_router(ai.router)
    return app


app = create_app()
