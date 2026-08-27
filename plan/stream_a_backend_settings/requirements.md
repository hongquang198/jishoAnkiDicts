# Stream A Requirements: Backend, Settings & Cloud Persistence

## 1. Scope & Objectives
Stream A covers server synchronization, settings automation, language onboarding, and database persistence for AI-generated study data.

---

## 2. Detailed Functional Requirements

### Requirement 1: Server-Side Sync for LLM Settings (User Task 1)
- Currently, Gemini API key, selected model, and custom prompt are stored locally in `SharedPreferences`.
- When an account is active (including Firebase Anonymous Auth session or linked Google/Email account), these settings must be synchronized with Firestore at `/users/{uid}/settings/config`.
- Remote settings must be pulled during user login/switching and pushed when local settings are updated in `LlmSettingsBloc`.

### Requirement 2: Automatic Model Loading from API Key (User Task 2)
- In the LLM Settings section (`LlmSettingsSection`), users should not have to manually click the "Fetch from API" button.
- When an API key is pasted or entered, automatically trigger model loading with a debounce delay (600ms).
- Display a smooth inline indicator while models are being fetched. If fetching completes, auto-select a valid model if the current one is blank.

### Requirement 3: Language Onboarding & Settings Management (User Task 3)
- If the app is launched for the first time (`hasCompletedLanguageSetup == false`), navigate to a `LanguageSelectionScreen`.
- Support selection of:
  - **Source Language (Native Language)**: Vietnamese (`vi` - default) or English (`en`).
  - **Target Language (Language to Learn)**: Japanese (`ja` - default).
- Save selection in local `SharedPref` immediately and sync to `/users/{uid}/settings/config` on authentication.
- Add a dedicated "Source & Target Language" section in `SettingsScreen` allowing users to edit languages later.

### Requirement 8: Persist AI Tutor Comments & Memory Tips in WordCard Database (User Task 8)
- When a user bookmarks a word or adds a card to the review deck, persist the AI-generated tutor comment (which bundles borrowed word etymology if applicable) and memory tip to SQLite `user_data.db` and Firestore `/users/{uid}/cards/{cardId}`.
- Update `WordCard` entity, SQLite schema in `UserLocalDataSourceImpl`, and Firestore push/pull converters with `aiTutorComment` and `aiMemoryTip`.

---

## 3. Non-Functional Requirements
- **Local-First & Offline Resilience**: Local storage always acts as the immediate cache.
- **Backwards Compatibility**: Existing `user_data.db` databases must gracefully migrate without data loss.
- **TDD Requirement**: All new repositories, use cases, and BLoC events must have unit tests.
