# 00 — Overview: route, monorepo, budget

## Decision (locked)

- **Stack:** Python FastAPI + PostgreSQL + Redis. You know Python from DSA;
  FastAPI+Pydantic maps 1:1 to `WordCard.toMap()`. Node only if you target
  React/RN next — not needed since UI is Flutter.
- **Scope:** side-by-side prototype. Firebase stays; `RestUserDataDataSource`
  toggled by flag. Proves swappability (your README already promises
  "pluggable remote backend adapters").
- **Auth:** full parity (anon + email + Google link) but split: P1 anon+email,
  P2 Google verify.
- **Hosting:** local Docker first (easy logs/breakpoints), then free cloud
  (Render/Fly + Neon) with the same image.

## Monorepo map

```text
jishoAnkiDicts/
  lib/core/data/datasources/
    remote_user_data_data_source.dart  # contract (unchanged)
    firebase_user_data_data_source.dart# existing impl (unchanged)
    rest_user_data_data_source.dart    # P1 Flutter work (new, in 06-)
  backend/
    app/ tests/ plan/ Dockerfile docker-compose.yml
```

## Time budget (~15-25h)

- P1 core: 8-12h (auth, CRUD, Postgres, Docker, 3 green tests).
- P2 differentiator: 6-10h (Google, Redis, AI proxy, CI, deploy).
- P3 senior-signal: optional 4-8h.

## What Firebase was hiding (your syllabus)

Auth tokens, `firestore.rules` ownership, batch commits, `where(updated_at>=)`,
offline `is_synced` protocol, LWW merge, secret management, deploy/logs.
Each phase makes one of these explicit — see `01-junior-checklist.md`.
