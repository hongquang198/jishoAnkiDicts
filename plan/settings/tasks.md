# Implementation Tasks: Backend Settings, Sync & Persistence

## Task 1: Domain Entities & Database Schema Migration (TDD)
- [x] **Sub-task 1.1**: Update `WordCard` in `lib/core/domain/entities/user_data/word_card.dart` to add `aiTutorComment` and `aiMemoryTip` fields with serialization in `toMap()` / `fromMap()`.
- [x] **Sub-task 1.2**: Create `UserSettingsEntity` in `lib/core/domain/entities/user_data/user_settings_entity.dart`.
- [x] **Sub-task 1.3**: Update `UserLocalDataSourceImpl` (`lib/core/data/datasources/user_local_data_source_impl.dart`) with DB version `2` and `onUpgrade` executing `ALTER TABLE` for `user_cards` and `lookup_history`.
- [x] **Sub-task 1.4**: Update `test/user_local_data_source_test.dart` to assert storage and retrieval of the new AI fields.

## Task 2: Remote Settings Synchronization
- [x] **Sub-task 2.1**: Add `pushSettings` and `pullSettings` methods to `RemoteUserDataDataSource` and `LocalUserDataDataSource`.
- [x] **Sub-task 2.2**: Implement Firestore settings storage in `FirebaseUserDataDataSource` (`/users/{uid}/settings/config`).
- [x] **Sub-task 2.3**: Update `UserDataRepositoryImpl` to synchronize settings during `syncWithRemote()`.
- [x] **Sub-task 2.4**: Add unit tests for settings remote push/pull in `test/remote_user_data_source_test.dart` and `test/user_data_repository_test.dart`.

## Task 3: Auto-Fetch Models in LLM Settings (Debounced)
- [x] **Sub-task 3.1**: Refactor `LlmSettingsBloc` to add automated debounce handling on `UpdateApiKeyEvent`.
- [x] **Sub-task 3.2**: Update `LlmSettingsSection` UI to remove the manual fetch requirement and display auto-fetching progress indicator.
- [x] **Sub-task 3.3**: Write unit tests in `test/llm_settings_bloc_test.dart` verifying automatic model fetching upon key input.

## Task 4: Language Onboarding & Settings Section
- [x] **Sub-task 4.1**: Add `sourceLanguage`, `targetLanguage`, and `hasCompletedLanguageSetup` properties to `SharedPref`.
- [x] **Sub-task 4.2**: Implement `LanguageSelectionScreen` in `lib/features/onboarding/screens/language_selection_screen.dart` with source/target language pickers.
- [x] **Sub-task 4.3**: Integrate onboarding router guard in `lib/config/app_routes.dart` to show language selection on first run.
- [x] **Sub-task 4.4**: Create `LanguageSettingsSection` widget in `lib/features/settings/screens/widgets/language_settings_section.dart` and integrate into `SettingsScreen`.
- [x] **Sub-task 4.5**: Add unit/widget tests for language selection and preference persistence.

## Task 5: Verification
- [x] **Sub-task 5.1**: Run `flutter analyze` on touched packages.
- [x] **Sub-task 5.2**: Run `flutter test` across all updated test suites.
