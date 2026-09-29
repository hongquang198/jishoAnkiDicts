# JishoAnki custom backend (side-by-side Firestore replacement)
# Stack: FastAPI + PostgreSQL. See plan/ for the learning roadmap.

## Quickstart (local, no cloud needed)

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8000
# health: http://localhost:8000/health
# docs:   http://localhost:8000/docs
# LAN/physical phone: uvicorn app.main:app --host 0.0.0.0 --reload --port 8000
# lib/core/config/backend_config.dart at the PC Wi-Fi IPv4.
```

With Postgres (Session 14):

```powershell
docker compose up -d db
docker compose exec db pg_isready -U jisho
# docker compose logs db
# docker compose down
docker compose up -d redis
docker compose exec redis redis-cli ping
```


## Command runbook (each entry earned in its session)

```powershell
# env (S00): pip install -r requirements.txt
# serve (S01): uvicorn app.main:app --reload --port 8000
# tests (S02/S06/S11/S12): python -m pytest -q
# migrations (S14): alembic revision --autogenerate -m "<msg>"; alembic upgrade head
# containers (S14): docker compose up -d db; exec; logs; ps; down
```

## Layout

- `app/main.py` — app factory, router wiring only.
- `app/core/` — config, JWT/bcrypt helpers, auth dependency.
- `app/db/` — engine/session factory; models live in `app/models/`.
- `app/models/` — SQLAlchemy tables + Pydantic contracts mirroring Dart `toMap()` keys.
- `app/routers/` — one file per resource: auth, cards, views, logs, settings, ai (P2 stub), health.
- `app/services/sync.py` — pure LWW-merge helpers (unit-tested, no I/O).
- `tests/` — TDD spec: contract tests first, implementation follows.
- `plan/` — transition plan (start at `plan/00-overview.md`).

## Browse the database (pgAdmin, dev only)

```powershell
docker compose up -d pgadmin   # web UI, first boot takes ~30s
```

Open http://localhost:5050, login `admin@example.com` / `admin`, then
Add Server: General → Name `jisho`; Connection → Host `db`, Port `5432`,
Username `jisho`, Password `jisho` (save it). Host is `db`, not localhost —
pgAdmin connects from inside the compose network (same rule as the api service).
Browse: Servers → jisho → Databases → jisho → Schemas → public → Tables →
right-click a table → View/Edit Data → All Rows.
Lighter alternatives: TablePlus / DBeaver / VS Code PostgreSQL extension
(connect to `localhost:5432` from the desktop).

Compose setup behind it (`docker-compose.yml`):

```yaml
pgadmin:
  image: dpage/pgadmin4:8
  environment:
    PGADMIN_DEFAULT_EMAIL: admin@example.com  # must be valid-shaped
    PGADMIN_DEFAULT_PASSWORD: admin
    PGADMIN_CONFIG_SERVER_MODE: 'False'
  ports:
    - "5050:80"  # host:container — pgAdmin serves :80 internally
  depends_on:
    - db
```

## Configuration files (what each command reads)

- `.env` (git-ignored; copy from `.env.example`) — `DATABASE_URL` (sqlite dev /
  postgres `postgresql+psycopg://jisho:jisho@localhost:5432/jisho`), `JWT_SECRET`,
  `JWT_ALG`, `ACCESS_TOKEN_MINUTES`. Read by `app/core/config.py` (`Settings`).
- `docker-compose.yml` — `db` service (`postgres:16-alpine`, user/pass/db `jisho`,
  port `5432`, data in `pgdata` volume); `api` override points `DATABASE_URL` at
  host `db`; `pgadmin` browser (see above).
- `lib/core/config/backend_config.dart` (Flutter) — `useRest` toggle + `apiBaseUrl`
  (`http://10.0.2.2:8000` emulator, PC Wi-Fi IPv4 for physical phone,
  `http://localhost:8000` iOS sim/desktop). No run flags needed.
- `alembic.ini` — `script_location = alembic`, `sqlalchemy.url` (overridden by `.env`
  at runtime via `env.py`); plus the logging sections `env.py` requires.
- `pytest.ini` — `testpaths = tests`, so bare `pytest` just works.
- `requirements.txt` — pinned deps (see header comment for what each group does).

## Architecture (how the pieces interact)

```
Flutter app (physical phone / emulator)
  lib/core/config/backend_config.dart ── useRest toggle + apiBaseUrl
  rest_auth_data_source.dart ── mints/stores JWT (AuthBloc, lazy:false, owns identity)
  rest_user_data_data_source.dart ── 12 contract methods → 8 HTTP endpoints
            │  Bearer token per request
            ▼
FastAPI app (uvicorn :8000) — app/main.py wires routers only
  routers/auth.py ── POST /auth/anon|signup|login|link-email, GET /me
  routers/cards|views|logs|settings.py ── bulk-PUT push, ?since= GET pull
            │  every route declares its needs
            ▼
Guards + sessions (per request, resolved by FastAPI)
  core/deps.py ── get_current_user_id: Bearer → 401 or user_id  (firestore.rules)
  db/session.py ── get_db: open → yield → close (never a global)
            │
            ▼
Logic + persistence
  services/sync.py ── pure LWW merge (no I/O, unit-tested)
  models/db.py ── users/cards/word_views/review_logs/user_settings,
                      every PK carries user_id (ownership as data)
            │  SQLAlchemy ORM
            ▼
Postgres 16 (docker `db`, data in `pgdata` volume — survives restarts)

Sidecars (same compose network, hostnames not localhost):
  pgadmin (:5050→:80) ── browser UI, connects to host "db"
  api (deploy shape) ── same image, DATABASE_URL host "db"

Out of band (no runtime traffic):
  alembic/ ── versions/*.py migrate the schema; upgrade head converges every env
  core/config.py + .env ── secrets per machine, never in code
  tests/ ── TestClient calls the app in-process (no server needed)
```
## Deploy migrations (every deploy, not just the first)

Schema changes ship as Alembic revisions (`alembic/versions/`). `alembic upgrade head`
applies only pending scripts in order and records them in `alembic_version` —
re-running it is a safe no-op, so it belongs in the deploy pipeline itself:

- **Render free tier (this project):** no pre-deploy hooks, so the image migrates on
  boot instead (`Dockerfile CMD` runs `alembic upgrade head` before uvicorn; no-op when
  current). **Render paid:** Settings -> **Pre-Deploy Command** = `alembic upgrade head`.
- **Local one-off** (first Neon setup, emergencies):
  `$env:DATABASE_URL="<neon-string>"; .\.venv\Scripts\alembic upgrade head; Remove-Item Env:\DATABASE_URL`
- **New schema change workflow:** edit `app/models/db.py` →
  `alembic revision --autogenerate -m "<what>"` → review the script → commit → push.
  CI proves it applies clean; deploy applies it to prod automatically.