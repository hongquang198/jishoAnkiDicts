# 04 — P2 differentiator (6-10h, the hireable edge)

Do after P1 exit criteria. Each item is independently shippable.

## 1. Google link (2h) — `POST /auth/link-google` (now 501)

- Verify `id_token` against Google JWKS (`google-auth` lib), check `aud ==
  GOOGLE_CLIENT_ID`, extract `sub`.
- If another user owns that `google_sub`, merge-or-409 (mirror
  `FirebaseAuthDataSource.linkAccountWithGoogle` fallback to sign-in).
- Test: fake-token unit test (rejects), real-token manual test.

Learn: OAuth vs password auth, `aud`/`exp` validation, account-linking races.

## 2. Redis cache + rate-limit (2h)

- Cache: `GET /cards?since=` + Wikimedia/gloss responses, key
  `uid:{since}:{hash}`, TTL 60-300s; invalidate on `PUT /bulk`.
- Rate-limit AI + bulk writes with `slowapi` (e.g. 30/min anon, 120/min user).
- Run `docker compose up redis`, show hit-rate in logs.

Learn: cache invalidation, hot keys, why rate-limit before LLM spend.

## 3. AI proxy (3h, biggest ROI) — `POST /ai/explain`

Move `LlmService` off client keys:

1. Request `{word, source_lang, model, prompt_version}`; hash ->
   cache lookup (Redis, then `ai_cache` table).
2. Miss: check quota (`ai_usage` per user/day), call Gemini server-side
   with secret from env (never shipped to app), store + return.
3. Quota exceeded -> 429 with `Retry-After`; log prompt/model/latency.

Learn: server-side secrets, caching economics, quotas, eval-ready logging.
Portfolio line: "cut LLM cost N% via caching + quotas."

## 4. Tests + CI + deploy (2-3h)

- Integration test (new `tests/test_sync_api.py`): anon -> push 2 cards ->
  pull since -> delete -> 404-safe; two users isolated.
- CI `.github/workflows/backend.yml`: `pip install -r backend/requirements.txt`
  + `pytest backend` (+ existing `flutter analyze` job untouched).
- Deploy same `Dockerfile` to Render/Fly + Neon free Postgres; set
  `JWT_SECRET`, `GOOGLE_CLIENT_ID`, `CORS_ORIGINS` in dashboard; tail logs,
  hit `/health` publicly.

## P2 exit criteria

- [ ] Google link works with a real account; anon cards preserved.
- [ ] Redis hits visible; rate-limit returns 429 when abused.
- [ ] `/ai/explain` cached second call (no Gemini call in logs).
- [ ] Public URL + CI badge; can demo phone app pointed at cloud API.
