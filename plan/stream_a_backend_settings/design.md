# Stream A Design: Backend, Settings & Persistence

## 1. System Architecture & Cloud Sync Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
│  (LlmSettingsBloc, LanguageSettingsBloc, AuthBloc, UI)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Streams / Events)
┌──────────────────────────────▼──────────────────────────────┐
│                         Domain Layer                        │
│   (UserDataRepository, UserSettingsEntity, WordCard)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                          Data Layer                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                 UserDataRepositoryImpl                │  │
│  └─────────────┬───────────────────────────┬─────────────┘  │
│                │                           │                │
│    ┌───────────▼───────────┐   ┌───────────▼───────────┐    │
│    │ UserLocalDataSource   │   │ FirebaseUserData-     │    │
│    │ (SQLite: user_data.db)│   │ DataSource (Firestore)│    │
│    └───────────────────────┘   └───────────┬───────────┘    │
└────────────────────────────────────────────┼────────────────┘
                                             │
                                 ┌───────────▼───────────┐
                                 │ Cloud Firestore       │
                                 │ /users/{uid}/settings/│
                                 │ /users/{uid}/cards/   │
                                 └───────────────────────┘
```

---

## 2. Key Decisions & Rationale

> **[DECISION A1] Config Storage Document in Firestore**:
> User settings are stored at doc path `/users/{uid}/settings/config`.
> Schema:
> ```json
> {
>   "llm_api_key": "AIzaSy...",
>   "llm_model": "gemini-2.0-flash",
>   "llm_custom_prompt": "...",
>   "llm_enabled": true,
>   "llm_genui_enabled": true,
>   "source_language": "Tiếng Việt",
>   "target_language": "Japanese",
>   "has_completed_language_setup": true,
>   "updated_at": 1724600000000
> }
> ```

> **[DECISION A2] WordCard SQLite & Firestore Schema Expansion**:
> `user_cards` and `lookup_history` tables in `user_data.db` gain 2 columns:
> - `ai_tutor_comment TEXT`
> - `ai_memory_tip TEXT`
> (Borrowed word etymology is bundled directly into `ai_tutor_comment`).
> Database version upgraded from `1` to `2` in `UserLocalDataSourceImpl` with `ALTER TABLE` migrations.

> **[DECISION A3] Debounced Auto-Fetch in `LlmSettingsBloc`**:
> Using Rx or `Timer` debouncer (600ms) on `UpdateApiKeyEvent`. When a key of length >= 30 is detected, it dispatches `FetchAvailableModelsEvent` automatically without user intervention.

---

## 3. Data Contracts & Interfaces

### 3.1 `UserSettingsEntity`
```dart
class UserSettingsEntity {
  final String llmApiKey;
  final String llmModel;
  final String llmCustomPrompt;
  final bool llmEnabled;
  final bool llmGenUiEnabled;
  final String sourceLanguage;
  final String targetLanguage;
  final bool hasCompletedLanguageSetup;
  final int updatedAt;
  
  const UserSettingsEntity({...});
}
```

### 3.2 `RemoteUserDataDataSource` Expansion
```dart
abstract class RemoteUserDataDataSource {
  // Existing card, view, review_log methods...
  
  Future<void> pushSettings(UserSettingsEntity settings);
  Future<UserSettingsEntity?> pullSettings();
}
```

### 3.3 `WordCard` Entity Updated Fields
```dart
class WordCard {
  // Existing fields...
  final String? aiTutorComment;
  final String? aiMemoryTip;
}
```
