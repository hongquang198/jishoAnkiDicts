# Stream A Implementation Tasks: Backend, Settings & Persistence

## Task A.1: Domain Entities & Database Schema Migration (TDD)
- [ ] **Sub-task A.1.1**: Update `WordCard` in `lib/core/domain/entities/user_data/word_card.dart` to add `aiTutorComment` and `aiMemoryTip` fields with serialization in `toMap()` / `fromMap()`.
- [ ] **Sub-task A.1.2**: Create `UserSettingsEntity` in `lib/core/domain/entities/user_data/user_settings_entity.dart`.
- [ ] **Sub-task A.1.3**: Update `UserLocalDataSourceImpl` (`lib/core/data/datasources/user_local_data_source_impl.dart`) with DB version `2` and `onUpgrade` executing `ALTER TABLE` for `user_cards` and `lookup_history`.
- [ ] **Sub-task A.1.4**: Update `test/user_local_data_source_test.dart` to assert storage and retrieval of the new AI fields.

## Task A.2: Remote Settings Synchronization
- [ ] **Sub-task A.2.1**: Add `pushSettings` and `pullSettings` methods to `RemoteUserDataDataSource` and `LocalUserDataDataSource`.
- [ ] **Sub-task A.2.2**: Implement Firestore settings storage in `FirebaseUserDataDataSource` (`/users/{uid}/settings/config`).
- [ ] **Sub-task A.2.3**: Update `UserDataRepositoryImpl` to synchronize settings during `syncWithRemote()`.
- [ ] **Sub-task A.2.4**: Add unit tests for settings remote push/pull in `test/remote_user_data_source_test.dart` and `test/user_data_repository_test.dart`.

## Task A.3: Auto-Fetch Models in LLM Settings (Debounced)
- [ ] **Sub-task A.3.1**: Refactor `LlmSettingsBloc` to add automated debounce handling on `UpdateApiKeyEvent`.
- [ ] **Sub-task A.3.2**: Update `LlmSettingsSection` UI to remove the manual fetch requirement and display auto-fetching progress indicator.
- [ ] **Sub-task A.3.3**: Write unit tests in `test/llm_settings_bloc_test.dart` verifying automatic model fetching upon key input.

## Task A.4: Language Onboarding & Settings Section
- [ ] **Sub-task A.4.1**: Add `sourceLanguage`, `targetLanguage`, and `hasCompletedLanguageSetup` properties to `SharedPref`.
- [ ] **Sub-task A.4.2**: Implement `LanguageSelectionScreen` in `lib/features/onboarding/screens/language_selection_screen.dart` with source/target language pickers.
- [ ] **Sub-task A.4.3**: Integrate onboarding router guard in `lib/config/app_routes.dart` to show language selection on first run.
- [ ] **Sub-task A.4.4**: Create `LanguageSettingsSection` widget in `lib/features/settings/screens/widgets/language_settings_section.dart` and integrate into `SettingsScreen`.
- [ ] **Sub-task A.4.5**: Add unit/widget tests for language selection and preference persistence.

## Task A.5: Verification
- [ ] **Sub-task A.5.1**: Run `flutter analyze` on touched packages.
- [ ] **Sub-task A.5.2**: Run `flutter test` across all updated test suites.
