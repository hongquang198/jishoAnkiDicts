# Requirements Specification: User Data Revamp & Swappable Backend

## 1. Objective
To completely revamp user data persistence, spaced-repetition system (SRS), word view analytics, bookmarks/favorites, history lookups, and statistics in `jisho_anki` by introducing an offline-first architecture with a pluggable, swappable remote backend (Firebase by default, with clean modular abstractions allowing drop-in replacement with Supabase, Appwrite, or custom REST APIs).

## 2. Core Functional Requirements

### 2.1 Word View Tracking
- **Dedicated View Counter**: Word lookup views must be decoupled from SRS review counts into a distinct `WordViewRecord` (tracking `word`, `viewCount`, `firstViewedAt`, `lastViewedAt`).
- **Debounced View Recording**: Looking up a word increments view count once per unique session view, avoiding duplicate counts during rapid navigation.
- **Reactive UI Badge**: The `WordViewCountWidget` must reactively display the real-time view count on `DefinitionScreen` and `SavedDefinitionScreen`.

### 2.2 Spaced Repetition System (SRS) & Review Engine
- **Standardized Algorithm**: Implement SuperMemo-2 (SM-2) with support for 4 response grades: `Again` (1), `Hard` (2), `Good` (3), and `Easy` (4).
- **Deck & Card Lifecycle**: Support card states: `New`, `Learning`, `Review`, `Relearning`.
- **Card Metadata**: Track `dueAt`, `interval` (in days/minutes), `easeFactor` (default 2.5), `reviewCount`, `lapseCount`, `lastReviewedAt`.
- **Leech Management**: Suspend or flag cards reaching the configurable leech threshold without destroying card history.
- **Session Queue**: Build a deterministic session queue (due cards sorted by `dueAt`, followed by new cards up to daily limits).
- **Undo Capability**: Provide multi-step or single-step undo for reviews within the active session.

### 2.3 Favorites & Bookmarks
- **Instant Toggle**: Add/remove words to/from favorites from any screen (`MainSearchScreen`, `DefinitionScreen`, `CommonQueryTile`).
- **Reactive Sync**: Toggling a favorite updates all visible UI tiles across the application simultaneously via reactive streams/BLoC.
- **Organization**: Support timestamps (`savedAt`) and optional tag filtering.

### 2.4 History Lookup
- **Chronological History**: Maintain a deduplicated, timestamp-indexed history of word and grammar lookups.
- **Search & Clear**: Enable searching within history and clearing all/selected history entries.
- **Separation from Dict Asset**: Store history independently of the static dictionary SQLite database.

### 2.5 Study Statistics & Activity Heatmap
- **Real-Time Due Metrics**: Dynamic count of `New`, `Learning/Young`, `Mature`, and `Difficult/Leech` cards due today.
- **7-Day Forecast (Prediction Chart)**: Dynamic 7-day forecast with actual relative calendar dates (Today + 1..6 days).
- **Study Activity Heatmap**: Contribution/activity heatmap showing reviews and lookups per calendar day over time.
- **Retention Rate**: Calculate user retention accuracy percentage across review logs.

## 3. Non-Functional & Architectural Requirements

### 3.1 Swappable / Pluggable Backend Architecture
- **Clean Architecture Ports**: Define domain repository interfaces (`UserDataRepository`, `ReviewRepository`, `FavoriteRepository`, `HistoryRepository`, `WordStatRepository`) and data source interfaces (`IRemoteUserDataDataSource`, `AuthRemoteDataSource`).
- **Pluggable Backend**: Initial implementation uses Firebase (Firestore + Firebase Auth with Anonymous sign-in support).
- **Zero-Coupling Contract**: Domain and Presentation layers must have ZERO references to Firebase SDK packages. Swapping Firebase for Supabase, Appwrite, or custom REST API requires only implementing `IRemoteUserDataDataSource` and re-registering in GetIt.

### 3.2 Offline-First Reliability
- **Local-First Writes**: All user actions are written immediately to the local cache database (`user_data.db`) for instant UI response without network latency.
- **Sync Engine**: Background synchronization queues pending changes and synchronizes bidirectionally with the backend when online.
- **Conflict Resolution**: Deterministic Last-Write-Wins (LWW) resolution based on UTC `updatedAt` timestamps.

### 3.3 State Management & Testing
- **BLoC**: Implement distinct BLoCs: `ReviewBloc`, `FavoriteBloc`, `HistoryBloc`, `StatisticsBloc`, and `WordInteractionBloc`.
- **TDD (Test-Driven Development)**: Comprehensive unit tests for SRS algorithm calculations, sync logic, and repository contracts before UI integration.
