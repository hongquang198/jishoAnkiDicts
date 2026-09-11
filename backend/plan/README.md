# Backend-engineer transition plan — index

Goal: replace Firestore with your own FastAPI backend **side-by-side**,
and in doing so cover 100% of junior-BE hiring signals.

| # | Doc | Outcome |
|---|---|---|
| 0 | `00-overview.md` | route decision, monorepo map, time budget |
| T | `00-tutor-sessions.md` | **guided-rebuild tracker (start here)** — 15 sessions, tick as you go |
| 1 | `01-junior-checklist.md` | what "100% junior BE" means + gap analysis |
| 2 | `02-schema-contract.md` | Firestore -> SQL translation, endpoint contract |
| 3 | `03-p1-core.md` | P1 build: auth + CRUD + Postgres + Docker (hireable core) |
| 4 | `04-p2-differentiator.md` | P2: Google auth, Redis, AI proxy, tests, deploy |
| 5 | `05-p3-senior-signal.md` | P3: jobs, S3, FTS, observability |
| 6 | `06-flutter-integration.md` | Flutter adapter swap without touching Blocs |

Rule: TDD — each phase starts with the test command that must go green.
Do phases in order; don't start P2 until P1 exit criteria pass.
