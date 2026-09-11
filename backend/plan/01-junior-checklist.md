# 01 — Junior-BE checklist (2026) + gap analysis

Based on 2026 postings (Node/Python, Postgres, Redis, Docker, CI/CD, JWT/OAuth,
pytest, observability) and your codebase audit.

## Must-have (P1 covers)

- [ ] HTTP/REST: methods, status codes, versioning — `PUT /cards/bulk`,
  `GET /cards?since=`, `DELETE /cards/{id}` (see 02-).
- [ ] Auth: bcrypt (never plaintext), JWT issue/verify/expiry, Bearer
  middleware replacing `firestore.rules`.
- [ ] SQL: SELECT/INSERT/UPDATE/DELETE, JOINs, indexes on `(user_id, updated_at)`,
  transactions, Alembic migrations. Raw SQL for at least one stats query.
- [ ] ORM + migrations: SQLAlchemy models in `app/models/db.py`, `alembic upgrade head`.
- [ ] Validation/errors: Pydantic schemas (`app/models/schemas.py`), 401/403/422/409.
- [ ] Git + CI basics: one workflow running `pytest` + `flutter analyze`.

## Must-have (P2 covers — differentiator)

- [ ] OAuth: verify Google `id_token` via JWKS, link by `google_sub`
  (`POST /auth/link-google`, currently 501).
- [ ] Caching + rate-limit: Redis for Wikimedia/gloss cache, `slowapi` limiter.
- [ ] AI backend: `POST /ai/explain` proxy with cache-by-(word,lang,model),
  per-user quota, prompt versioning. Moves `LlmService` off client keys.
- [ ] Tests: unit (LWW in `test_sync.py`) + contract (`test_auth_contract.py`)
  + integration (anon->push->pull->delete) with testcontainers-postgres.
- [ ] Docker + deploy: `Dockerfile` + `docker-compose.yml` local, then
  Render/Fly + Neon free tier, env-based secrets, CORS.
- [ ] Observability: structured logs, `/health`, request-id, Sentry.

## Senior-signal (P3, optional)

- [ ] Async/jobs: Celery+Redis precompute `SrsEngine.computeStats()`/heatmap.
- [ ] Object storage: S3 presigned upload for `.apkg` backup/avatar.
- [ ] Search: Postgres FTS on cards (`tsvector`), pagination `limit+cursor`.
- [ ] Realtime (bonus): SSE for sync status; WebSockets only if asked.

## Gap analysis: what P1 skeleton already gives you

`app/` boots (`test_health.py`), LWW rules tested (`test_sync.py`),
ownership enforced (`test_auth_contract.py`), tables mirror Firestore keys.
Missing (your work): wire `get_db` to real Postgres, Alembic revision,
Google verify, Redis, AI proxy, CI workflow, cloud deploy — each mapped
to a phase doc with exit criteria.

## Interview lines this project earns

- "Replaced document rules with row-ownership middleware + tests."
- "Implemented offline LWW sync with tombstones; covered by unit tests."
- "Moved LLM keys server-side with caching + quotas to control cost."
