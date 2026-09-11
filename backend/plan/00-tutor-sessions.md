# 00 — Tutor sessions (guided rebuild, one concept at a time)

Mode: **you type every file**; the current `backend/` code is the answer key
to peek at when stuck. Each session: 1 concept → type → run proof →
1-sentence recap + the interview line it earns. Tick boxes as we go.

## Sessions

- [ ] **00 — Orientation.** Concept: request→app→response; venv/what pip does.
  Files: none (tour + installs). Proof: `python --version`, venv activates,
  `pip install -r requirements.txt` succeeds.
- [ ] **01 — Routing + generator detour.** Concept: a URL maps to a function;
  uvicorn serves it. Files: `app/main.py`, `app/routers/health.py`.
  Proof: `uvicorn app.main:app --reload`, `/health` returns `ok` in browser.
  Detour (15 min): generate the official `fastapi-new` scaffold into a scratch
  folder, compare layout vs ours, note what we'd delete (React/Traefik/etc).
- [ ] **02 — Tests as spec.** Concept: TestClient fakes HTTP, no server needed.
  Files: `tests/test_health.py`. Proof: `pytest` green.
- [ ] **03 — Contracts.** Concept: Pydantic rejects bad JSON with 422.
  Files: `app/models/schemas.py` (one model first). Proof: bad JSON in
  `/docs` → readable 422.
- [ ] **04 — Hashing.** Concept: passwords are never stored.
  Files: `security.py` (hash/verify). Proof: python one-liner verifies a pw.
- [ ] **05 — Tokens.** Concept: JWT = signed JSON with expiry, stateless auth.
  Files: `security.py` (+ token fns). Proof: decode token at jwt.io, expiry works.
- [ ] **06 — Guards.** Concept: dependency = code version of firestore.rules.
  Files: `app/core/deps.py`, `tests/test_auth_contract.py`. Proof: no/bogus
  token → 401, contract test green.
- [ ] **07 — Config.** Concept: secrets from env, never code.
  Files: `app/core/config.py`, `.env.example`. Proof: change `.env` →
  behavior changes, code untouched.
- [ ] **08 — Tables.** Concept: Firestore docs → rows with PKs.
  Files: `app/db/base.py`, `app/models/db.py`. Proof: tables exist in SQLite.
- [ ] **09 — Connections.** Concept: session-per-request, no global.
  Files: `app/db/session.py`. Proof: endpoint reads DB cleanly.
- [ ] **10 — First real endpoint.** Concept: request→DB→response.
  Files: `app/routers/auth.py` (anon + me). Proof: token → `/me` returns id.
- [ ] **11 — Sync logic first.** Concept: LWW as pure functions, tested pre-DB.
  Files: `app/services/sync.py`, `tests/test_sync.py`. Proof: `pytest` green.
- [ ] **12 — CRUD.** Concept: bulk-push + since-pull + delete.
  Files: `app/routers/cards.py`. Proof: push 2 → pull → delete in `/docs`.
- [ ] **13 — Repetition (80% solo).** Concept: same pattern, new rules
  (max-wins, append-only, single-row). Files: `views.py`, `logs.py`,
  `settings.py`. Proof: all green — growth check.
- [ ] **14 — Real DB.** Concept: migrations + containers.
  Files: alembic revision, `docker-compose.yml`, `Dockerfile`.
  Proof: data survives API restart; `docker compose up --build` works.

## Rules

- Sessions 00–10 need only Python. Docker/Postgres wait until 14.
- Red output is the lesson: we read the error together, never skip it.
- `ai.py` stays stubbed until P2 (`04-p2-differentiator.md`).
