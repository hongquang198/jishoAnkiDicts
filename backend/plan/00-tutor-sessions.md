# 00 — Tutor sessions (guided rebuild, one concept at a time)

Mode: **you type every file**; the current `backend/` code is the answer key
to peek at when stuck. Each session: 1 concept → type → run proof →
1-sentence recap + the interview line it earns. Tick boxes as we go.

## Sessions

- [x] **00 — Orientation.** Concept: request→app→response; venv/what pip does.
  Files: none (tour + installs). Proof: `python --version`, venv activates,
  `pip install -r requirements.txt` succeeds.
  DONE 2026-09-11: venv live, fastAPI 0.115.0, 8 tests collected, 0 errors.
  Detour fixed: psycopg 3.1.18→3.2.9 (no cp313-win wheel), pinned bcrypt 4.0.1.
- [x] **01 — Routing + generator detour.** Concept: a URL maps to a function;
  uvicorn serves it. Files: `app/main.py`, `app/routers/health.py`.
  Proof: `uvicorn app.main:app --reload`, `/health` returns `ok` in browser.
  DONE 2026-09-11: `{"status": "ok"}` in browser. Detour: `uvx fastapi-new`
  (needs `pip install uv`) — compare its layout vs answer key when tried.
  CORS deferred: only needed when a *browser* client calls the API (P2 deploy).
- [x] **02 — Tests as spec.** Concept: TestClient fakes HTTP, no server needed.
  Files: `tests/test_health.py`. Proof: `pytest` green.
  DONE 2026-09-14: `1 passed` — TestClient replaces the browser click.
- [x] **03 — Contracts.** Concept: Pydantic rejects bad JSON with 422.
  Files: `app/models/schemas.py` (one model first). Proof: bad JSON in
  `/docs` → readable 422.
  DONE 2026-09-14: `CardIn` validates good input, `ValidationError: id Field required` on bad input.
- [x] **04 — Hashing.** Concept: passwords are never stored.
  Files: `security.py` (hash/verify). Proof: python one-liner verifies a pw.
  DONE 2026-09-14: `$2b$` prefix, same pw → different hashes, True/False verifies.
- [x] **05 — Tokens.** Concept: JWT = signed JSON with expiry, stateless auth.
  Files: `security.py` (+ token fns). Proof: decode token at jwt.io, expiry works.
  DONE 2026-09-14: `eyJhbGciOi...` → `u_123` / `None`; payload `{sub, exp}` confirmed.
- [x] **06 — Guards.** Concept: dependency = code version of firestore.rules.
  Files: `app/core/deps.py`, `tests/test_auth_contract.py`. Proof: no/bogus
  token → 401, contract test green.
  DONE 2026-09-14: guard written; contract tests red with 404 (no /cards route yet
  → guard never runs). Green deferred to S12 when cards.py declares the guard.
- [x] **07 — Config.** Concept: secrets from env, never code.
  Files: `app/core/config.py`, `.env.example`. Proof: change `.env` →
  behavior changes, code untouched.
  DONE 2026-09-14: `change-me-in-env` → `audio-jungle` via `.env` only; security.py rewired to settings.
- [x] **08 — Tables.** Concept: Firestore docs → rows with PKs.
  Files: `app/db/base.py`, `app/models/db.py`. Proof: tables exist in SQLite.
  DONE 2026-09-14: 5 tables created; (user_id, id) PK = per-user data separation.
- [x] **09 — Connections.** Concept: session-per-request, no global.
  Files: `app/db/session.py`. Proof: endpoint reads DB cleanly.
  DONE 2026-09-15: `0` printed; detour — `.env` Postgres URL caused hang, fixed to SQLite.
- [x] **10 — First real endpoint.** Concept: request→DB→response.
  Files: `app/routers/auth.py` (anon + me). Proof: token → `/me` returns id.
  DONE 2026-09-15: `201 anon_...` → `/me` echoes same id; KeyError from missing
  include_router self-diagnosed and fixed; trace (get_db runs, no guard on /anon) correct.
- [x] **11 — Sync logic first.** Concept: LWW as pure functions, tested pre-DB.
  Files: `app/services/sync.py`, `tests/test_sync.py`. Proof: `pytest` green.
  DONE 2026-09-15: 5 passed; full suite 6 passed + 2 expected reds (auth contract, awaiting S12).
- [x] **12 — CRUD.** Concept: bulk-push + since-pull + delete.
  Files: `app/routers/cards.py`. Proof: push 2 → pull → delete in `/docs`.
  DONE 2026-09-15: `8 passed` — S06 contract tests green with zero test edits.
  Gloss rule adopted: comments live in code (AGENTS.md).
- [x] **13 — Repetition (80% solo).** Concept: same pattern, new rules
  (max-wins, append-only, single-row). Files: `views.py`, `logs.py`,
  `settings.py`. Proof: all green — growth check.
  DONE 2026-09-15: all 3 routers round-trip; fixed missing-slash 404s,
  review_at/reviewed_at mismatch, r.id bomb, `or`-precedence, None-settings.
- [x] **14 — Real DB.** Concept: migrations + containers.
  Files: alembic revision, `docker-compose.yml`, `Dockerfile`.
  Proof: data survives API restart; `docker compose up --build` works.
  DONE 2026-09-16: Postgres 16-alpine up; `upgrade head` applied (6 tables);
  full suite green against Postgres; pg1 survived `restart db` with same token.

## Rebuild complete — 15/15 (2026-09-16). Adapter complete — A1/A2/A3 (2026-09-17).
## P2 COMPLETE (2026-09-18): Google link, Redis cache + rate limits, AI proxy
## (+retired-model fallback), dual CI green, Render+Neon live with boot migrations.
## Next: P3 options or the structured-proxy phase (fetchWordInfo gap-fill).

## Rules

- Sessions 00–10 need only Python. Docker/Postgres wait until 14.
- Red output is the lesson: we read the error together, never skip it.
- `ai.py` stays stubbed until P2 (`04-p2-differentiator.md`).
