# 02 — Schema + endpoint contract (Firestore -> SQL)

Source of truth: `lib/core/data/datasources/firebase_user_data_data_source.dart`
+ `WordCard.toMap()`, `ReviewLog.toMap()`, `WordViewRecord.toMap()`,
`UserSettingsEntity.toMap()`.

## Tables (see `app/models/db.py`)

| Firestore | SQL table | PK | Notes |
|---|---|---|---|
| `users/{uid}` (auth) | `users` | `id` | `email UNIQUE`, `google_sub UNIQUE`, `is_anonymous` |
| `users/{uid}/cards/{cardId}` | `cards` | `(user_id, id)` | `updated_at INDEX`; JSON columns stored as TEXT (`tags/jlpt/senses/srs_data`) exactly like Flutter `json.encode` |
| `users/{uid}/views/{word}` | `word_views` | `(user_id, word)` | max-wins on `view_count` |
| `users/{uid}/review_logs/{logId}` | `review_logs` | `(user_id, id)` | append-only, `reviewed_at INDEX` |
| `users/{uid}/settings/config` | `user_settings` | `(user_id)` | single row per user |

Ownership: **every** query filters `user_id == token.sub`. That's the
`firestore.rules: request.auth.uid == userId` replacement.

## Endpoints (see `app/routers/`)

```text
POST /auth/anon | POST /auth/signup | POST /auth/login
POST /auth/link-email | POST /auth/link-google (P2) | GET /auth/me
PUT  /cards/bulk  {cards:[WordCardIn]}   # pushCards (batch upsert, LWW)
GET  /cards?since=ms                     # pullCardsUpdatedSince
DELETE /cards/{id}                       # deleteCard
PUT  /views/bulk  {views:[WordViewIn]}   # pushViews (max-wins)
GET  /views
PUT  /logs/bulk   {logs:[ReviewLogIn]}   # pushReviewLogs (insert-if-absent)
GET  /logs?since=ms
PUT  /settings    {...UserSettingsIn}    # pushSettings
GET  /settings
POST /ai/explain  {word,lang,model}      # P2, 501 in P1
GET  /health
```

Field names intentionally mirror Dart `toMap()` snake_case keys so the
Flutter diff is mechanical. Pydantic `422` on bad shapes is the new
"Firestore silently accepted anything" fix.

## Sync semantics (see `app/services/sync.py`)

- Cards: apply remote iff `!tombstoned && remote.updated_at > local.updated_at`.
- Views: apply remote iff `remote.view_count > local.view_count`.
- Logs: insert-if-absent (never update).
- Deletes: client tombstone set wins; server hard-deletes on `DELETE`.
