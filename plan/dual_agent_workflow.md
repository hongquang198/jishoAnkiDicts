# Dual-Agent Architecture & Simultaneous Execution Workflow

## 1. Overview
This document defines the interface boundary, file ownership, and coordination protocol between **AI Instance 1 (Settings & Sync)** and **AI Instance 2 (AI Features & Chat)** for concurrent development on `jisho_anki`.

---

## 2. Key Decisions & Architectural Rationale

> **[DECISION 1] Offline-First Cloud Settings Sync**:
> Local `SharedPref` remains the synchronous source of truth for the UI so that startup and searches are 100% instant and zero-latency. Cloud synchronization to Firestore (`/users/{uid}/settings/config`) occurs in the background. Because Firebase Anonymous Auth assigns a `uid` to all users upon first app launch, there is no need for divergent "Guest vs User" branching in the UI.

> **[DECISION 2] Debounced Model Auto-Detection**:
> Instead of requiring a manual click on "Fetch from API", entering a valid API key triggers a 600ms debounced auto-query in `LlmSettingsBloc`. If the list of models is successfully fetched and the current model is unselected or missing, it automatically sets the recommended default model (`gemini-2.0-flash`).

> **[DECISION 3] Language Hierarchy & Defaults**:
> `sourceLanguage` is the user's native language (default: `Vietnamese` / `Tiếng Việt`, with `English` support).
> `targetLanguage` is the language the user is learning (default: `Japanese` / `Tiếng Nhật`).
> On initial launch when `hasCompletedLanguageSetup == false`, users are routed to `LanguageSelectionScreen` to configure or confirm these choices.

> **[DECISION 4] Schema & AI Field Bundling**:
> `WordCard` schema in SQLite (`user_cards`, `lookup_history`) and Firestore adds `ai_tutor_comment` and `ai_memory_tip`. Borrowed word etymology (origin language, original word) is bundled directly into `ai_tutor_comment` by the AI prompt rather than using a separate column, keeping the schema clean.

> **[DECISION 5] Dedicated Multi-Turn AI Chat Route (`/ai_chat`)**:
> Instead of cramped modal bottom sheets, AI conversation uses a full dedicated screen (`AiChatScreen`) backed by `GenerativeModel.startChat()`. Preloaded context (canonical word, reading, JLPT, definition, current AI tutor notes, and grammar breakdowns) is fed into the chat session as initial system history.

---

## 3. Workstream Division & File Ownership

```
┌────────────────────────────────────────────────────────────┐
│                    SHARED DOMAIN BOUNDARY                  │
│       WordCard Entity (fields: tutorComment, memoryTip)    │
│       SharedPref (keys: source/target language, llm keys)   │
└─────────────────────────────┬──────────────────────────────┘
                              │
             ┌────────────────┴────────────────┐
             ▼                                 ▼
┌──────────────────────────────┐ ┌──────────────────────────────┐
│   SETTINGS & SYNC            │ │   AI FEATURES & CHAT         │
│ Backend, Sync & Settings     │ │ AI Components, UI & Chat     │
├──────────────────────────────┤ ├──────────────────────────────┤
│ Core Responsibilities:       │ │ Core Responsibilities:       │
│ • Task 1: Server-side sync   │ │ • Task 4 & 6: Reusable AI    │
│   for API key, model, prompt │   widgets & loading skeletons  │
│ • Task 2: Auto-load model    │ │ • Task 5: Memory tips in     │
│   from API key with debounce │   definition & grammar pages   │
│ • Task 3: Language selection │ │ • Task 9: Borrowed word info │
│   onboarding & settings      │   (etymology / origin)         │
│ • Task 8: Persist AI tutor   │ │ • Task 10: Multi-turn AI     │
│   comment & tips in DB       │   chat screen with context     │
├──────────────────────────────┤ ├──────────────────────────────┤
│ Exclusive File Ownership:    │ │ Exclusive File Ownership:    │
│ • lib/core/data/datasources/ │ │ • lib/common/widgets/ai/*    │
│   user_local_data_source_impl│ • lib/services/llm_service.dart│
│ • lib/core/data/datasources/ │ • lib/services/llm/gen_ui_*    │
│   firebase_user_data_data_src│ • lib/features/word_definition/│
│ • lib/features/settings/*    │   screens/widgets/definition_* │
│ • lib/features/onboarding/*  │ • lib/features/single_grammar_ │
│ • test/user_local_data_src_* │   point/*                      │
│ • test/llm_settings_bloc_test│ • lib/features/ai_chat/*       │
│                              │ • test/ai_chat_bloc_test.dart  │
└──────────────────────────────┘ └──────────────────────────────┘
```

---

## 4. Cross-Stream Integration Testing Checklist
1. `flutter analyze` passes across all paths with zero warnings.
2. `flutter test` runs all domain and BLoC unit tests.
3. Settings & Sync workstream verifies remote sync and database migrations.
4. AI Features & Chat workstream verifies AI UI rendering, shimmer loading, and multi-turn chat interactions.
