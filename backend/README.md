# JishoAnki custom backend (side-by-side Firestore replacement)
# Stack: FastAPI + PostgreSQL + Redis. See plan/ for the learning roadmap.

## Quickstart (local, no cloud needed)

```powershell
cd backend
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8000
# health: http://localhost:8000/health
# docs:   http://localhost:8000/docs
```

With Postgres + Redis:

```powershell
docker compose up --build
```

## Layout

- `app/main.py` — app factory, router wiring (stateless, no business logic).
- `app/core/` — config, JWT/bcrypt helpers, auth dependency (single responsibility each).
- `app/db/` — engine/session factory only. Models live in `app/models/`.
- `app/models/` — SQLAlchemy tables + Pydantic contracts mirroring Flutter `toMap()` keys.
- `app/routers/` — one file per resource: auth, cards, views, logs, settings, ai (P2 stub), health.
- `app/services/sync.py` — pure LWW-merge helpers (unit-tested, no I/O).
- `tests/` — TDD spec: contract tests first, implementation follows.
- `plan/` — full backend-engineer transition plan (start at `plan/00-overview.md`).
