# FILE: app/models/db.py
# WHAT: SQL tables mirroring Firestore users/{uid}/{cards,views,review_logs,settings}.
# WHY: Every row carries user_id in its PK — that IS the ownership rule that
#   firestore.rules enforced. updated_at/reviewed_at indexes power ?since= pulls.
# NOTE: JSON-ish columns stay TEXT, exactly like Flutter's json.encode output.
# TUTOR SESSION: 08 — see backend/plan/00-tutor-sessions.md.
"""SQL translation of Firestore `users/{uid}/{cards,views,review_logs,settings}`.

Ownership rule (was firestore.rules): every row carries user_id and all
queries filter on it. Composite PKs enforce per-user uniqueness.
"""
from sqlalchemy import BigInteger, Boolean, Float, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class User(Base):
    __tablename__ = 'users'
    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    email: Mapped[str | None] = mapped_column(String(320), unique=True)
    password_hash: Mapped[str | None] = mapped_column(String(255))
    google_sub: Mapped[str | None] = mapped_column(String(128), unique=True)
    is_anonymous: Mapped[bool] = mapped_column(Boolean, default=True)


class Card(Base):
    __tablename__ = 'cards'
    user_id: Mapped[str] = mapped_column(
        String(64), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True
    )
    id: Mapped[str] = mapped_column(String(128), primary_key=True)
    word: Mapped[str] = mapped_column(String(128), default='')
    slug: Mapped[str] = mapped_column(String(128), default='')
    reading: Mapped[str] = mapped_column(String(128), default='')
    is_common: Mapped[int] = mapped_column(BigInteger, default=0)
    tags: Mapped[str] = mapped_column(Text, default='[]')
    jlpt: Mapped[str] = mapped_column(Text, default='[]')
    senses: Mapped[str] = mapped_column(Text, default='[]')
    localized_definition: Mapped[str] = mapped_column(Text, default='')
    gloss_lang: Mapped[str] = mapped_column(String(16), default='')
    is_favorite: Mapped[int] = mapped_column(BigInteger, default=0)
    srs_data: Mapped[str | None] = mapped_column(Text)
    added_at: Mapped[int] = mapped_column(BigInteger, default=0)
    updated_at: Mapped[int] = mapped_column(BigInteger, default=0, index=True)
    deck: Mapped[str] = mapped_column(String(64), default='default')
    ai_tutor_comment: Mapped[str | None] = mapped_column(Text)
    ai_memory_tip: Mapped[str | None] = mapped_column(Text)


class WordView(Base):
    __tablename__ = 'word_views'
    user_id: Mapped[str] = mapped_column(
        String(64), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True
    )
    word: Mapped[str] = mapped_column(String(128), primary_key=True)
    view_count: Mapped[int] = mapped_column(BigInteger, default=1)
    first_viewed_at: Mapped[int] = mapped_column(BigInteger, default=0)
    last_viewed_at: Mapped[int] = mapped_column(BigInteger, default=0)


class ReviewLog(Base):
    __tablename__ = 'review_logs'
    user_id: Mapped[str] = mapped_column(
        String(64), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True
    )
    id: Mapped[str] = mapped_column(String(128), primary_key=True)
    card_id: Mapped[str] = mapped_column(String(128), default='')
    rating: Mapped[str] = mapped_column(String(16), default='good')
    duration_ms: Mapped[int] = mapped_column(BigInteger, default=0)
    reviewed_at: Mapped[int] = mapped_column(BigInteger, default=0, index=True)
    prev_interval_ms: Mapped[int] = mapped_column(BigInteger, default=0)
    new_interval_ms: Mapped[int] = mapped_column(BigInteger, default=0)
    prev_ease: Mapped[float] = mapped_column(Float, default=2.5)
    new_ease: Mapped[float] = mapped_column(Float, default=2.5)


class UserSettings(Base):
    __tablename__ = 'user_settings'
    user_id: Mapped[str] = mapped_column(
        String(64), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True
    )
    llm_api_key: Mapped[str] = mapped_column(Text, default='')
    llm_model: Mapped[str] = mapped_column(String(128), default='gemini-2.0-flash')
    llm_custom_prompt: Mapped[str] = mapped_column(Text, default='')
    llm_enabled: Mapped[int] = mapped_column(BigInteger, default=1)
    llm_gen_ui_enabled: Mapped[int] = mapped_column(BigInteger, default=1)
    source_language: Mapped[str] = mapped_column(String(64), default='Tiếng Việt')
    target_language: Mapped[str] = mapped_column(String(64), default='Japanese')
    has_completed_language_setup: Mapped[int] = mapped_column(BigInteger, default=0)
    updated_at: Mapped[int] = mapped_column(BigInteger, default=0)
