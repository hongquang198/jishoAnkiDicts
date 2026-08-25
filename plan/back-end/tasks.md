# Implementation Tasks: User Data Revamp & Swappable Backend

## Task 1: Domain Entities, SRS Engine & Contracts (TDD)
- **Sub-task 1.1**: Define immutable pure Dart models (`WordCard`, `SrsData`, `ReviewLog`, `WordViewRecord`, `UserStudyStats`) in `lib/core/domain/entities/user_data/`.
- **Sub-task 1.2**: Implement `SrsEngine` service implementing the 4-tier SM-2 algorithm with configurable intervals and leech thresholds.
- **Sub-task 1.3**: Write unit tests for `SrsEngine` (testing all 4 grades, learning transitions, ease calculations, lapses, and leech handling).
- **Sub-task 1.4**: Define repository and data source interfaces (`UserDataRepository`, `IRemoteUserDataDataSource`, `ILocalUserDataDataSource`).

## Task 2: Dedicated Local Storage Layer & Migration
- **Sub-task 2.1**: Implement `UserLocalDatabase` helper creating `user_data.db` with clean relational tables for cards, views, history, and review logs.
- **Sub-task 2.2**: Implement one-time migration utility to import existing favorites, history, and review items from `offlineDatabase.db` into `user_data.db`.
- **Sub-task 2.3**: Write unit tests for `UserLocalDatabase` CRUD and migration operations.

## Task 3: Remote Backend Abstraction & Firebase Adapter
- **Sub-task 3.1**: Add `firebase_core`, `firebase_auth`, and `cloud_firestore` to `pubspec.yaml` (or configure conditional backend factory).
- **Sub-task 3.2**: Implement `FirebaseUserDataDataSource` implementing `IRemoteUserDataDataSource` with Firestore collections and anonymous auth.
- **Sub-task 3.3**: Implement Mock/In-Memory remote data source for testing and standalone offline mode.
- **Sub-task 3.4**: Write unit/integration tests for remote data source serialization and operations.

## Task 4: Sync Engine & Repository Implementation
- **Sub-task 4.1**: Implement `UserDataRepositoryImpl` orchestrating local database access with remote sync and conflict resolution.
- **Sub-task 4.2**: Implement domain use cases (`GetFavoritesStream`, `ToggleFavorite`, `GetReviewSession`, `SubmitReviewGrade`, `RecordWordView`, `GetStudyStats`, `GetHistoryStream`, `ClearHistory`).
- **Sub-task 4.3**: Register new data sources, repositories, and use cases in `lib/injection.dart`.
- **Sub-task 4.4**: Write unit tests for repository and use cases with mocked local and remote sources.

## Task 5: State Management (BLoC Layer)
- **Sub-task 5.1**: Implement `WordInteractionBloc` for reactive favorite toggling, review deck toggling, and view count tracking across search tiles.
- **Sub-task 5.2**: Implement `ReviewBloc` managing session card queue, 4-button review actions, session progress, and undo history.
- **Sub-task 5.3**: Implement `FavoriteBloc` and `HistoryBloc` with reactive stream bindings and search/filter events.
- **Sub-task 5.4**: Implement `StatisticsBloc` providing aggregated daily due counts, 7-day prediction data, and review activity logs.
- **Sub-task 5.5**: Write BLoC unit tests using `bloc_test` for all events and states.

## Task 6: UI Revamp & Screen Integration
- **Sub-task 6.1**: Refactor `ReviewScreen` to use `ReviewBloc`, 4-tier answer buttons (`Again`, `Hard`, `Good`, `Easy`), countdown timer, and safe empty state.
- **Sub-task 6.2**: Refactor `FavoriteScreen` and `HistoryScreen` to use `FavoriteBloc` and `HistoryBloc` with reactive lists.
- **Sub-task 6.3**: Refactor `WordViewCountWidget`, `DefinitionScreen`, and `CommonQueryTile` to use `WordInteractionBloc`.
- **Sub-task 6.4**: Refactor `StatisticsScreen`, `TodayDueChart`, `PredictionChart` (with dynamic weekday dates), and implement `ActivityHeatmapWidget`.

## Task 7: Verification & Documentation
- **Sub-task 7.1**: Run `flutter analyze` and targeted `flutter test` suites to verify all new and existing tests pass.
- **Sub-task 7.2**: Update `@README.md` and documentation describing the new swappable backend architecture and SRS features.
