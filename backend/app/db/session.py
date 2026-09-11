# FILE: app/db/session.py
# WHAT: Engine + SessionLocal factory + get_db dependency.
# WHY: Routers ask for a DB session per request (via Depends(get_db)) instead
#   of sharing one global connection — safe under concurrency.
# NOTE: DATABASE_URL picks SQLite (learning) vs Postgres (real) — same code.
# TUTOR SESSION: 09 — see backend/plan/00-tutor-sessions.md.
"""SQLAlchemy engine/session factory. Routers depend on `get_db`, never on a global."""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

engine = create_engine(settings.database_url, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
