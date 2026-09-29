# Concepts log — misses & truths (guided rebuild)

Append one entry per session **only when I get something wrong or half-right**.
Correct answers get one line under "Clean wins" so this file stays a miss-collection, not a diary.

Format per entry: session topic → what I said → the truth → the one-liner to remember.

## Misses

### S04 — Hashing (bcrypt salt)
- **What I said:** two hashes of the same password differ because the hash function has timing encoded in it; different timestamp each time makes it harder to deduce the hash function.
- **The truth:** each `hash_password` call generates a fresh **random salt** (16 bytes), mixes it with the password through bcrypt, and stores `salt + hash` together in the `$2b$12$...` string. No timestamps involved. The point is defeating **rainbow tables**: without salt, identical passwords hash identically everywhere and one precomputed dictionary cracks every database; with unique salts each hash must be attacked individually.
- **Remember:** same password → different hash *by design* (salt), and verification re-hashes with the stored salt.

### S08 — Mapped vs mapped_column
- **What I asked:** is `Mapped` a converter that turns string/JSON text into Python/DB types to speed things up? Does `mapped_column()` return the `Mapped` type?
- **The truth:** no conversion, no speed-up — it's pure *declaration*. `Mapped[str]` (left) tells the type-checker "this attribute is persisted, holding a `str`"; `mapped_column(String(64), ...)` (right) tells the database "this column is VARCHAR(64)". `str | None` just means nullable. Translation between Python objects and DB rows happens automatically at read/write time.
<!-- What do you mean by "this attribute is persisted"?
    Is Mapped a type in Python? why not just declare it str then?
 -->
- **Remember:** left side = Python type, right side = DB column spec; a `Base` subclass with `__tablename__` is purely a DB-mapping class.

### S05 — Tokens (JWT secret placement)- **What I said:** jwt_secret is stored in the server's RAM (global variable) and never revealed to clients.
- **The truth:** essentially correct. The secret lives on the server (currently a module-level constant, moving to env/config in S07, loaded into process memory at startup). Clients receive only **signed tokens** — they can read the payload but cannot mint or forge one without the secret. Caveat learned: my `get_payload_str` helper verifies the signature (good for debugging), but it must never become an endpoint that decodes *unverified* tokens.
- **Remember:** server holds the secret, clients hold signed tokens, expiry bounds the damage of leaks.

## Clean wins (one line each)

- **S02 — TestClient:** fakes HTTP in-process, no browser/server needed; tests automate what testers would otherwise repeat by hand. Correct.
- **S03 — Contracts:** Pydantic gives JSON validation that Firestore never did; bad data fails fast. Correct.
- **S06 — Guards:** 401 = "who are you?" (bad/missing token), 403 = "I know you, but no" (valid identity, no permission); test accepts both so it asserts rejection, not framework wording. Routing runs before guards — no matched route → 404 without the guard ever executing. Correct.
- **S07 — Config:** secrets live in env/`.env`, never in code; git history is forever and bots harvest pushed secrets in minutes, so `.env` is git-ignored and only `.env.example` is committed. Correct.
- **S08 — Tables:** Firestore = NoSQL (nested docs, schemaless); our Postgres/SQLite = SQL (flat rows, declared schema). Ownership moves from path nesting to a `user_id` column in a composite PK, so each user holds their own copy of a word. Correct.
- **S08 — Base registry:** `class Base(DeclarativeBase)` = Dart's `extends`; one shared `Base` exists so all tables register in a single metadata registry (plus one extension point). `pass` = intentionally empty body. Correct.

### S09 (in progress) — the hang was env config, not code
- **Symptom:** S09 proof command hung indefinitely, no output.
- **Diagnosis chain:** imports fine → `create_all` hangs → printed `engine.url` → surprise: `postgresql+psycopg://...` instead of SQLite. The `.env` (copied in S07) still carried the old Postgres URL, which **overrides the code default** (that's the S07 lesson biting back). No Postgres running → connect blocks forever.
- **Fix:** point `.env`'s `DATABASE_URL` at `sqlite:///./jisho.db`; Postgres returns in S14. Also removed a duplicate `DATABASE_URL` in `.env.example`.
- **Remember:** when DB code hangs, first print the engine URL — verify *which database you're actually talking to* before suspecting anything else.
- **Correction (S09 close):** `jisho.db` DOES contain all 5 tables — `create_all` built them from the registry; the `import app.models.db` line is what registered them. Proof: inspected the file, all tables present.
- **S09 owed sentence (arrived S10):** shared global session → requests contaminate each other, users could see each other's data. Correct.
- **S10 — Base is never instantiated:** no `Base()` call exists anywhere. The registry (`Base.metadata`) is a *class-level* object built once at class-definition time; subclasses register into it by inheriting. Not a singleton pattern — just shared class state via inheritance.
- **S10 — Depends resolution:** yes, the framework calls it. FastAPI reads the signature at route-registration, and per request resolves the chain itself: header → `HTTPAuthorizationCredentials` → `get_current_user_id(creds)` → your `user_id`. You never pass `creds`; nothing "compiles" — mismatches surface at startup/registration, not via a compiler.
- **S10 — KeyError debugging:** `KeyError` on response JSON means the response wasn't the expected shape → print `status_code` + full body first (here it was a 404 from a missing `include_router`, self-fixed).
- **S10 — /anon is public on purpose:** can't require a token to issue someone's first token (chicken-and-egg); `get_db` runs, no guard. `/me` carries the guard.
- **S11 — Tombstones:** yes, `tombstoned=true` means "this card was deliberately deleted locally." The tombstone (Flutter's `_locallyDeletedCardIds`) exists so a later pull of an older remote copy doesn't resurrect the dead — deletion is information that must survive, not just absence. Correct question.
- **S11 — Pure functions:** merge rules isolated from I/O = plain unit tests, no server/DB setup, milliseconds. Testing through endpoints costs setup and resources per case. Correct.
- **S12 — Red-to-green without touching tests:** the S06 contract tests passed because the routes finally exist and declare their guards — routing matches first, guard runs, 401 flows. Spec-before-code vindicated. Correct.
- **S13 — Missing leading slash:** `prefix + path` concatenates literally, so `@router.put('bulk')` built `/viewsbulk`. One character, two 404s. Rule: paths start with `/`, always.
- **S13 — Schema names must mirror DB columns:** `review_at` vs `reviewed_at` would have 500'd every log push — masked until the slash fix. Same 1:1 discipline as mirroring Dart `toMap()` keys.
- **S13 — Empty tables hide bugs:** `r.id` on a model without `id`, `or`-precedence in a filter, None-settings — all invisible until real rows exist. Lesson: prove with populated data, not just empty responses.
- **S13 — Settings has no merge rule:** single-row resource, plain overwrite (last write wins by construction). No concurrent-merge semantics needed where there's exactly one row. Correct.
+ Recap: same shape, different rules — max-wins for counters, insert-if-absent for history, overwrite for single rows.
Interview line: "I choose merge semantics per resource — LWW for documents, max-wins for counters, append-only for history."
- **S14 — Docker detour chain:** (1) C: at 0 bytes free → layer commit I/O error → moved Docker disk image to D:. (2) `exec format error` on `postgres:16` (Debian) while `hello-world` ran fine → image-specific, not runtime → `postgres:16-alpine` works. Debugging order that paid off: engine ping → disk space → hello-world isolation → variant swap.
- **S14 — Alembic needs its logging sections:** skeleton `alembic.ini` had only `[alembic]`, so `env.py`'s `fileConfig()` crashed with `KeyError: 'formatters'` before any migration ran. The runner's config must satisfy the runner's code — fixed by adding the standard logger/handler/formatter sections.
- **S14 finale — statelessness + volumes, proven:** tokens survive DB restarts (nothing server-side to kill); a fresh anon sees empty cards (ownership filter, not data loss); `pg1` returned after `restart db` because rows live in the `pgdata` volume, not the container. README = happy path only; war stories stay in this log.

## Adapter (Flutter → custom backend)

- **A-config — reaching the API per target:** `localhost` = this machine only; emulator's `10.0.2.2` = host loopback (emulator-only); physical phone needs the PC's Wi-Fi IPv4 (`ipconfig`, here `192.168.0.104`) with uvicorn bound to `0.0.0.0` (default binds localhost = unreachable from LAN) plus a Windows Firewall allow. Selection lives in `BackendConfig` — a config file beats run flags because the value is per-machine, not per-run.
- **A-dead-bloc discovery:** `AuthBloc` is never instantiated anywhere in `lib/` — real auth lives in `main()` (direct Firebase anon sign-in) and the Firebase data source reads the SDK directly. So nothing ever called our REST anon: no token, every sync 401. Lesson: when porting a seam, trace who *calls* the old code, not just what it *implements*.
- **A-startup race (user-found):** `repo.init()` runs inside `inject()`, which completes before the first widget builds — so the opening sync could never have a token, structurally, not just by timing. Fixed in `UserDataRepositoryImpl.init()`: sync immediately if identity exists (Firebase path, unchanged), else wait for the first non-null `watchUserId` event (REST path, fires when the bloc mints anon). Two culprits, two fixes: bloc provides identity, repo waits for it.
- **A-lazy-provider trap (user-found):** `BlocProvider` is `lazy: true` by default — `create` runs on first `read`, not on insertion. Nothing reads `AuthBloc`, so the root provider never created it and anon never fired. Fix: `lazy: false`. Rule: providers nobody consumes must be eager; otherwise they're decoration.
- **A3 DONE — phone → API → Postgres:** `POST /auth/anon 201`, then `200`s across pulls/pushes; `退治` + its view row persisted under the phone's anon id. Per-user isolation held (probe rows untouched under other ids). The 3-bug board (dead bloc, structural race, lazy trap) is closed.
- **pgAdmin lessons:** Docker has no built-in DB browser — pgAdmin runs as a sibling container. Two setup traps, both mine: (1) `PGADMIN_DEFAULT_EMAIL` must be valid-shaped (`admin@example.com`, not `admin@local`); (2) port mapping is `host:container` and pgAdmin serves `:80` internally, so `"5050:80"`, not `"5050:5050"` — an empty target port answers with silence (`ERR_EMPTY_RESPONSE`). Rule: check what the container actually listens on (`Listening at:` in logs) before blaming the browser.

## P2 (hireable edge)

- **P2.4b — CI DONE:** `.github/workflows/backend.yml` green on first push (47s): fresh Postgres + Redis services per run, `alembic upgrade head` before `pytest` so migrations prove themselves every push. `paths:` filter keeps Flutter jobs untouched.
- **Flutter CI — suite audited, version pinned:** `flutter.yml` pins `3.47.0` (verified local) instead of floating `stable`. Full run: 114 pass, 14 fail — all 14 proven pre-existing via a clean-baseline worktree (`00a6df3`, same failures without our changes), so CI runs the 19 green files and documents the 3 excluded ones. Notably green: `auth_bloc`, `remote_user_data_source`, `user_data_repository` — our seam holds.
- **Flutter suite repaired (13 failures fixed, all one root cause class):** widget tests rotted as the product internationalized and relabeled around them — `AppLocalizations.of(context)!` needs delegates in the host (ai_cards), screens need their production `BlocProvider`s (prewarm + hand-rolled fake repo, no mockito needed), and three expectations named strings that no longer exist (`'common word'`→`'common'`, `' N4 '`→`'N4'`, `'Grammar Analysis'`→card title, `'AI Tutor Notes'`→`'AI Tutor Insights'`). Debugging shape that paid off: dump rendered texts (scratch probe) instead of guessing. Deleted the irrelevant default `widget_test.dart`; full suite now **127 green**, CI runs plain `flutter test`.

- **P2.2b — rate limits DONE:** slowapi `@limiter.limit('30/minute')` on the three pushes, identity-aware key (token tail, else IP). Proven: 35 rapid pushes → `{200: 30, 429: 5}`. Decorator lesson: `@x` = `f = x(f)` at import time — `router.put` *registers*, `limiter.limit` *wraps* (order matters); the `request: Request` param exists for the wrapper to inspect, not for your code. Dart equivalents: annotations (passive) vs manual higher-order wrapping vs middleware/interceptors (the pattern already in `http_client.dart`).

- **P2.1 — Google link DONE:** `POST /auth/link-google` verifies signature+aud+exp via `google-auth`, 409 on foreign ownership, preserves anon rows. Proven: bogus token → `501` unconfigured (→ `401` once a client id is set). Real-token test deferred until `GOOGLE_CLIENT_ID` is configured and the Flutter Google flow exists. Habit found: Docker Desktop dies with the PC — check `docker version` Server before any DB work.
- **P2.2 — cache placement (corrected):** not "one process per user" — one API process serves *all* users. In-Python dict fails because (1) multiple processes/workers don't share memory (reload, gunicorn workers, replicas → inconsistent views), (2) restarts wipe it (every deploy = cold cache), (3) unbounded growth. Redis is shared, independent-lifetime RAM.
- **P2.2 — TTL + invalidation are a pair:** TTL bounds staleness from unwatched writers; invalidation kills it from watched ones (push). Either alone leaves a hole (2-minute stale reads, or forever-stale).
- **P2.2 — two bugs, one hiding the other:** `settings.REDIS_URL` (uppercase) → AttributeError swallowed by the forgiving `except` → cache silently off; and pull key missing the `cards:` namespace the invalidation scans. Fixed by centralizing key builders in `cache.py` (one definition, used twice) and replacing the comment in `except` with a real `log.warning` — comments don't execute, logs make silence observable.
- **A-bloc resurrection (principled over hacky):** first fix bootstrapped identity in `main()`; proper fix registers an `AuthBloc` factory and provides it once at the widget-tree top with `..add(CheckAuthStatus())`, gated on `useRest` so Firebase is untouched. Why the bloc wins: AuthError surfaces failures to UI instead of swallowing them, and the email/Google events finally have a living owner for the future login screen. Also removed a no-op line in `close()`.
- **A-clean-install discipline:** when swapping backends, uninstall the app (wipe local DB + prefs) before the first proof run. Legacy Firebase-era rows and sync flags muddy the experiment — a tokenless 401 must be diagnosable as race-vs-failure, not as ghost state.

- **A1 — auth adapter:** `RestAuthDataSource` mints/persists/attaches JWTs; `analyze` clean.
- **P2.4c deploy (in progress):** Render + Neon (Singapore, Postgres 16). Fresh `JWT_SECRET` per env via `secrets.token_hex(32)`; `GOOGLE_CLIENT_ID` = existing `serverClientId` from `main.dart`.
- **Client ID vs client secret:** the OAuth client *ID* in `main.dart` is public by design (shipped in every app binary; Google treats it as an identifier, like `google-services.json` contents). The client *secret* is what must never touch public files or the app — server env only. Same split as JWT: `aud` (public descriptor) vs signing secret (private).
- **A2 — data adapter:** `RestUserDataDataSource` translates all 12 contract methods; `analyze` clean.
- **A-stream — why a StreamController, not a variable:** auth is a value that *changes over time* (anon → linked → signed-out), and multiple subscribers (`AuthBloc`, repo `watchUserId`) each need *push* updates. A variable can only be polled; a broadcast stream pushes every transition to every listener — the same reason Firebase exposes `authStateChanges()` as a stream, and our contract demands one.
- **AI proxy epoch:** `POST /ai/explain` (cache → quota → Gemini) + `LlmService` proxy branch via plain `http` (the SDK can't be repointed); `isApiKeyConfigured` true in REST mode kills `geminiKeyNotSet`; streaming gates rewired from raw-key checks to the single owner (gap-fill gates stay raw-key until the structured phase).
- **YAGNI reversal (user-found):** `useAiProxy` removed — the proxy requires `useRest` (needs our JWT), so no valid configuration distinguished them. One backend decision owns sync + AI routing; a second flag returns only with a documented reason.
