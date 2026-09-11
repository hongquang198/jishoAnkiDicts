# 03 — P1 core build (hireable minimum, 8-12h)

TDD entry: `cd backend; pytest` — 3 files must stay green while you build.

## Step 1 — run locally (30 min)

```powershell
cd backend
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8000
# http://localhost:8000/docs should list /auth /cards /views /logs /settings /health
```

Learn: FastAPI routing, Pydantic validation (send bad JSON, read 422),
Bearer errors (no token -> 401/403 per `test_auth_contract.py`).

## Step 2 — Postgres + migrations (2-3h)

1. `docker compose up db` (or local Postgres), set `DATABASE_URL` in `.env`.
2. Create tables: quick path `python -c "from app.db.base import Base; ..."`,
   then learn properly: `alembic init alembic`, one revision creating
   `users/cards/word_views/review_logs/user_settings` from `app/models/db.py`,
   `alembic upgrade head`, `alembic downgrade -1` + re-upgrade.
3. Learn: composite PKs, FK `ondelete=CASCADE`, `updated_at` indexes,
   `EXPLAIN` on `GET /cards?since=`, one raw-SQL stats query.

Exit: restart API with Postgres URL; `POST /auth/anon` -> token works.

## Step 3 — auth anon+email (2-3h)

Implemented in `app/routers/auth.py` + `app/core/security.py`.
Exercise manually in `/docs`:

1. `POST /auth/anon` -> `{user_id, access_token}`.
2. `GET /auth/me` with `Authorize: Bearer <token>` -> same id; bogus -> 401.
3. `POST /auth/signup`, `POST /auth/login`, `POST /auth/link-email`
   (signup anon token first, then link — mirrors `linkWithCredential`).
4. Check DB: `password_hash LIKE '$2b$...'` (bcrypt, never plaintext).

Learn: JWT `sub/exp`, short-lived access tokens, 401 vs 403 vs 409.

## Step 4 — sync CRUD loop (3-4h)

With one anon token, drive the Flutter protocol:

1. `PUT /cards/bulk` 2 cards -> `GET /cards?since=0` returns 2.
2. Re-PUT older `updated_at` -> unchanged (LWW); newer -> overwrites.
3. `DELETE /cards/{id}` -> gone; client tombstone concept (see 06-).
4. Same loop for `/views/bulk` (higher count wins) and `/logs/bulk`
   (duplicate id ignored), `PUT/GET /settings`.

Learn: batch upserts, idempotency, `ON CONFLICT` equivalent, ownership
leak test (user A token can't read user B cards).

## P1 exit criteria

- [ ] `pytest` green (health, LWW, auth contract).
- [ ] Manual anon->push->pull->delete loop works against Postgres.
- [ ] Can explain: JWT lifecycle, why composite PK, what LWW loses
  (concurrent edits) and why tombstones exist.
