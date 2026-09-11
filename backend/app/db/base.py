# FILE: app/db/base.py
# WHAT: Single DeclarativeBase all ORM models inherit from.
# WHY: Gives Alembic + the session factory one shared metadata registry —
#   without it, migrations can't "see" your tables.
# TUTOR SESSION: 08 — see backend/plan/00-tutor-sessions.md.
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass
