# 05 — P3 senior-signal (optional, 4-8h)

Pick at most two; each is an interview story on its own.

## A. Background jobs (Celery + Redis)

Move `SrsEngine.computeStats()` server-side: nightly worker precomputes
due-counts, 7-day forecast, heatmap into `study_stats_cache(user_id, day, payload)`.
Flutter `StatisticsBloc` reads cache instead of computing. Learn: queues,
retries, idempotent tasks, scheduled beats.

## B. Object storage (S3 presigned URLs)

`POST /backups/request-upload {filename}` -> presigned PUT; client uploads
`.apkg` direct to S3; `POST /backups/complete` records metadata. Learn:
never proxy bytes, signed-URL expiry, multipart.

## C. Full-text search

Postgres `tsvector` on `cards(word, reading, localized_definition)` +
`GET /cards/search?q=&limit=&cursor=`. Learn: GIN indexes, ranking,
cursor pagination (no `OFFSET` at scale).

## D. Observability hardening

Request-id middleware, structured JSON logs, Prometheus `/metrics`
(sync latency, 5xx rate), Sentry traces. Learn: what "production-ready"
means beyond "works locally."

Skip: microservices split, Kubernetes, GraphQL — over-engineering for
one API + one app (YAGNI).
