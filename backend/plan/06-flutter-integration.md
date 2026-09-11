# 06 — Flutter integration (swap without touching Blocs)

Good news: `UserDataRepositoryImpl` depends on the **abstract**
`RemoteUserDataDataSource`, not Firebase. Blocs stay untouched.

## Step 1 — new adapter (P1 Flutter work, 1 evening)

Create `lib/core/data/datasources/rest_user_data_data_source.dart`:

```dart
class RestUserDataDataSource implements RemoteUserDataDataSource {
  // dio via getIt<HttpsClient>(); baseUrl from --dart-define API_BASE_URL
  // or SharedPref flag; Bearer token from your new RestAuthDataSource.
  // pushCards -> PUT /cards/bulk {cards: c.map(toMap())}
  // pullCardsUpdatedSince -> GET /cards?since=ts -> WordCard.fromMap each
  // ... same for views/logs/settings/deleteCard
}
```

Create `lib/core/data/datasources/rest_auth_data_source.dart`
implementing `AuthRemoteDataSource` against `/auth/*`, persisting the
JWT in `SharedPref` (same keys pattern as `llmApiKey`).

## Step 2 — toggle in `injection.dart:114-118`

```dart
final useRest = const bool.fromEnvironment('USE_REST', defaultValue: false);
getIt.registerLazySingleton<RemoteUserDataDataSource>(
  () => useRest ? RestUserDataDataSource() : FirebaseUserDataDataSource());
```

Run: `flutter run --dart-define=USE_REST=true --dart-define=API_BASE_URL=http://10.0.2.2:8000`
(Android emulator host loopback). iOS simulator: `http://localhost:8000`.

## Step 3 — migration + verification

- `UserDataMigrator` already moved legacy SQLite -> local `user_data.db`;
  keep it. First REST sync pushes `getUnsyncedCards()` to your API —
  no data loss even if server is empty.
- Verify: favorite on device A -> `PUT /cards/bulk` in API logs ->
  fresh install + same login -> `GET /cards?since=0` restores favorite.
- Tombstones: delete locally -> `DELETE /cards/{id}`; remote must not
  resurrect (covered by `should_apply_remote_card` tombstone test).

## Step 4 — LLM tile via proxy (P2)

Point `LlmService` at `POST /ai/explain` when flag on; keep direct
Gemini path as fallback. Quota/429 surfaces in existing
`LlmSearchResultTile` error state — no new UI needed.

Never: run `dart format` on existing files; format only the two new
adapter files with `dart format` on creation.
