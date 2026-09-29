# FILE: Dockerfile — builds the deploy image: Python 3.12 + deps + app code.
# Same image runs locally (docker compose) and on Render/Fly (Session 14/P2).
# CMD starts uvicorn on 0.0.0.0:8000 (all interfaces — required in containers).
FROM python:3.12-slim
WORKDIR /srv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
COPY alembic.ini ./alembic.ini
# Migration scripts must ship too: Render's pre-deploy `alembic upgrade head`
# runs inside this image (P2.4c lesson — ini without scripts migrates nothing).
COPY alembic ./alembic
ENV PORT=8000
# Free tier has no pre-deploy hooks: migrate on every boot instead.
# `upgrade head` is a no-op when current, so this is safe per start.
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
