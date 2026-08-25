# Design Specification: User Data Revamp & Swappable Backend

## 1. System Architecture

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (ReviewBloc, FavoriteBloc, HistoryBloc, StatsBloc)   │
└───────────────────────────┬────────────────────────────┘
                            │ (Use Cases / Streams)
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│   (Entities: WordCard, SrsData, ReviewLog, ViewStat)   │
│   (Repository Interfaces: ReviewRepo, FavoriteRepo)    │
└───────────────────────────┬────────────────────────────┘
                            │ (Contracts)
┌───────────────────────────▼────────────────────────────┐
│                       Data Layer                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │             UserDataRepositoryImpl               │  │
│  │   (Orchestrates Local Storage + Remote Sync)     │  │
│  └─────────────┬──────────────────────┬─────────────┘  │
│                │                      │                │
│    ┌───────────▼──────────┐   ┌───────▼───────────┐    │
│    │ LocalUserDataStore   │   │ IRemoteUserData-  │    │
│    │ (Dedicated SQLite)   │   │ DataSource (Port) │    │
│    └──────────────────────┘   └───────┬───────────┘    │
└───────────────────────────────────────┼────────────────┘
                                        │ (Adapters)
                    ┌───────────────────┴───────────────────┐
                    │                                       │
        ┌───────────▼───────────┐               ┌───────────▼───────────┐
        │ FirebaseRemoteData-   │ (Default)     │ Supabase / REST /     │ (Future
        │ Source (Firestore)    │               │ Custom Remote Source  │  Plugins)
        └───────────────────────┘               └───────────────────────┘
```

## 2. Core Domain Entities

### 2.1 `WordCard`
```dart
class WordCard {
  final String id; // Unique ID (slug or UUID)
  final String word;
  final String slug;
  final String reading;
  final List<String> tags;
  final List<String> jlpt;
  final List<JishoWordSense> senses;
  final String vietnameseDefinition;
  final bool isFavorite;
  final SrsData? srsData;
  final int addedAt;
  final int updatedAt;
  final bool isSynced;
}
```

### 2.2 `SrsData`
```dart
enum SrsStage { newCard, learning, review, relearning }

class SrsData {
  final SrsStage stage;
  final int dueAt; // Epoch timestamp (ms)
  final int interval; // Interval in minutes (learning) or days (review)
  final double easeFactor; // Default: 2.5, min: 1.3
  final int stepIndex; // Current index in learning steps [1, 10]
  final int reviews;
  final int lapses;
  final int? firstReviewedAt;
  final int? lastReviewedAt;
  final bool isLeech;
}
```

### 2.3 `WordViewRecord` & `ReviewLog`
```dart
class WordViewRecord {
  final String word;
  final int viewCount;
  final int firstViewedAt;
  final int lastViewedAt;
}

class ReviewLog {
  final String id;
  final String cardId;
  final int rating; // 1: Again, 2: Hard, 3: Good, 4: Easy
  final int reviewDurationMs;
  final int reviewedAt;
  final int previousInterval;
  final int newInterval;
  final double previousEase;
  final double newEase;
}
```

## 3. Swappable Backend Contract (Ports & Adapters)

```dart
abstract class IRemoteUserDataDataSource {
  Future<void> initialize(String userId);
  Future<void> pushCard(WordCard card);
  Future<void> pushBatchCards(List<WordCard> cards);
  Future<void> deleteCard(String cardId);
  Future<List<WordCard>> pullCardsUpdatedSince(int timestamp);
  Stream<List<WordCard>> watchCards();
  
  Future<void> recordView(WordViewRecord record);
  Future<List<WordViewRecord>> pullViewRecords();
  
  Future<void> logReview(ReviewLog log);
  Future<List<ReviewLog>> pullReviewLogs({int? sinceTimestamp});
}
```

### 3.1 Default Adapter: `FirebaseUserDataDataSource`
- Uses Cloud Firestore with user data isolation:
  - `/users/{userId}/cards/{cardId}`
  - `/users/{userId}/views/{word}`
  - `/users/{userId}/review_logs/{logId}`
- Offline persistence enabled via Firestore local cache.
- Anonymous Auth for zero-friction user onboarding.

### 3.2 Swapping Backends in the Future:
- Implement `IRemoteUserDataDataSource` (e.g. `SupabaseUserDataDataSource`).
- Re-bind in `lib/injection.dart`:
  ```dart
  getIt.registerLazySingleton<IRemoteUserDataDataSource>(() => SupabaseUserDataDataSource());
  ```
- Zero edits needed in domain, use cases, BLoCs, or UI layers.

## 4. Local Persistence & Sync Engine

- **Dedicated User DB**: Separate user data from `offlineDatabase.db` into `user_data.db` with clean schema tables:
  - `user_cards` (`id`, `word`, `slug`, `reading`, `is_favorite`, `srs_stage`, `due_at`, `interval`, `ease_factor`, `step_index`, `reviews`, `lapses`, `updated_at`, `is_synced`)
  - `word_views` (`word`, `view_count`, `first_viewed_at`, `last_viewed_at`, `is_synced`)
  - `lookup_history` (`id`, `word`, `lookup_type`, `searched_at`, `is_synced`)
  - `review_logs` (`id`, `card_id`, `rating`, `duration_ms`, `reviewed_at`, `is_synced`)
- **Sync Workflow**:
  1. Write locally with `is_synced = 0`.
  2. Sync engine triggers push on connectivity or app resume.
  3. Remote listener streams changes from cloud and merges locally using `updatedAt` LWW.

## 5. Spaced Repetition Algorithm (SM-2 Spec)

- **Grading Scale**:
  - `Again (1)`: Reset step to 0; stage becomes `relearning`; lapses incremented; interval = `steps[0]`.
  - `Hard (2)`: Interval = current interval * 1.2; ease decreased by 0.15.
  - `Good (3)`: If in learning, advance to next step or graduate (interval = 1 day); if in review, interval = interval * easeFactor; ease unchanged.
  - `Easy (4)`: Graduate immediately; interval = easy interval (4 days); ease increased by 0.15.
