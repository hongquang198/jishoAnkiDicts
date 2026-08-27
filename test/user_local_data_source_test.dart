import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/local_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/user_data_migrator.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';
import 'package:jisho_anki/models/offline_word_record.dart';
import 'package:jisho_anki/services/db_manager.dart';

/// In-memory fake implementation of LocalUserDataDataSource for unit testing.
class FakeLocalUserDataDataSource implements LocalUserDataDataSource {
  final Map<String, WordCard> cards = {};
  final Map<String, WordViewRecord> views = {};
  final List<WordCard> history = [];
  final Map<String, ReviewLog> reviewLogs = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> upsertCard(WordCard card) async {
    cards[card.id] = card;
  }

  @override
  Future<void> upsertBatchCards(List<WordCard> batch) async {
    for (final c in batch) {
      cards[c.id] = c;
    }
  }

  @override
  Future<WordCard?> getCard(String id) async => cards[id];

  @override
  Future<List<WordCard>> getAllCards() async => cards.values.toList();

  @override
  Future<List<WordCard>> getFavorites() async =>
      cards.values.where((c) => c.isFavorite).toList();

  @override
  Future<List<WordCard>> getReviewCards() async =>
      cards.values.where((c) => c.isInReview).toList();

  @override
  Future<void> deleteCard(String id) async {
    cards.remove(id);
  }

  @override
  Future<void> recordView(String word, {int? timestamp}) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final existing = views[word];
    if (existing == null) {
      views[word] = WordViewRecord(
        word: word,
        viewCount: 1,
        firstViewedAt: now,
        lastViewedAt: now,
      );
    } else {
      views[word] = existing.copyWith(
        viewCount: existing.viewCount + 1,
        lastViewedAt: now,
      );
    }
  }

  @override
  Future<WordViewRecord?> getViewRecord(String word) async => views[word];

  @override
  Future<List<WordViewRecord>> getAllViewRecords() async =>
      views.values.toList();

  @override
  Future<void> addHistory(WordCard card) async {
    history.removeWhere((c) => c.id == card.id || c.word == card.word);
    history.insert(0, card);
  }

  @override
  Future<List<WordCard>> getHistory({int limit = 100}) async =>
      history.take(limit).toList();

  @override
  Future<void> deleteHistory(String id) async {
    history.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> clearHistory() async {
    history.clear();
  }

  @override
  Future<void> insertReviewLog(ReviewLog log) async {
    reviewLogs[log.id] = log;
  }

  @override
  Future<void> deleteReviewLog(String logId) async {
    reviewLogs.remove(logId);
  }

  @override
  Future<List<ReviewLog>> getReviewLogs({int? sinceTimestamp}) async {
    if (sinceTimestamp != null) {
      return reviewLogs.values
          .where((l) => l.reviewedAt >= sinceTimestamp)
          .toList();
    }
    return reviewLogs.values.toList();
  }

  @override
  Future<List<WordCard>> getUnsyncedCards() async =>
      cards.values.where((c) => !c.isSynced).toList();

  @override
  Future<List<WordViewRecord>> getUnsyncedViews() async =>
      views.values.where((v) => !v.isSynced).toList();

  @override
  Future<List<ReviewLog>> getUnsyncedReviewLogs() async =>
      reviewLogs.values.where((l) => !l.isSynced).toList();

  @override
  Future<void> markCardsSynced(List<String> cardIds) async {
    for (final id in cardIds) {
      if (cards.containsKey(id)) {
        cards[id] = cards[id]!.copyWith(isSynced: true);
      }
    }
  }

  @override
  Future<void> markViewsSynced(List<String> words) async {
    for (final word in words) {
      if (views.containsKey(word)) {
        views[word] = views[word]!.copyWith(isSynced: true);
      }
    }
  }

  @override
  Future<void> markReviewLogsSynced(List<String> logIds) async {
    for (final id in logIds) {
      if (reviewLogs.containsKey(id)) {
        final log = reviewLogs[id]!;
        reviewLogs[id] = ReviewLog(
          id: log.id,
          cardId: log.cardId,
          rating: log.rating,
          reviewDurationMs: log.reviewDurationMs,
          reviewedAt: log.reviewedAt,
          previousIntervalMs: log.previousIntervalMs,
          newIntervalMs: log.newIntervalMs,
          previousEase: log.previousEase,
          newEase: log.newEase,
          isSynced: true,
        );
      }
    }
  }
}

/// Fake DbManager for testing migration.
class FakeLegacyDbManager extends DbManager {
  final Map<String, List<OfflineWordRecord>> legacyTables;

  FakeLegacyDbManager({required this.legacyTables})
      : super(dbName: 'fakeOfflineDb');

  @override
  Future<List<OfflineWordRecord>> retrieve({required String tableName}) async {
    return legacyTables[tableName] ?? [];
  }
}

void main() {
  group('LocalUserDataDataSource Operations Tests', () {
    late FakeLocalUserDataDataSource localDb;

    setUp(() {
      localDb = FakeLocalUserDataDataSource();
    });

    test('Upsert and retrieve favorite cards', () async {
      final card = WordCard(
        id: '日',
        word: '日',
        isFavorite: true,
        addedAt: 1000,
        updatedAt: 1000,
        aiTutorComment: 'Sun / Day character with pictographic roots',
        aiMemoryTip: 'Imagine a window showing the sun rising',
      );

      await localDb.upsertCard(card);
      final fetched = await localDb.getCard('日');
      expect(fetched, isNotNull);
      expect(fetched!.isFavorite, isTrue);
      expect(fetched.aiTutorComment, equals('Sun / Day character with pictographic roots'));
      expect(fetched.aiMemoryTip, equals('Imagine a window showing the sun rising'));

      final favorites = await localDb.getFavorites();
      expect(favorites.length, equals(1));
      expect(favorites.first.word, equals('日'));
    });

    test('Record word views increments view count reactively', () async {
      await localDb.recordView('本', timestamp: 1000);
      await localDb.recordView('本', timestamp: 2000);
      await localDb.recordView('本', timestamp: 3000);

      final record = await localDb.getViewRecord('本');
      expect(record, isNotNull);
      expect(record!.viewCount, equals(3));
      expect(record.firstViewedAt, equals(1000));
      expect(record.lastViewedAt, equals(3000));
    });

    test('History deduplication keeps most recent item at index 0', () async {
      final cardA = WordCard(id: 'A', word: 'A', addedAt: 100, updatedAt: 100);
      final cardB = WordCard(id: 'B', word: 'B', addedAt: 200, updatedAt: 200);

      await localDb.addHistory(cardA);
      await localDb.addHistory(cardB);
      await localDb.addHistory(cardA); // Re-look up A

      final history = await localDb.getHistory();
      expect(history.length, equals(2));
      expect(history[0].id, equals('A'));
      expect(history[1].id, equals('B'));
    });

    test('Review log insertion and sync marking', () async {
      final log = ReviewLog(
        id: 'log123',
        cardId: 'card1',
        rating: SrsRating.good,
        reviewedAt: 5000,
        isSynced: false,
      );

      await localDb.insertReviewLog(log);
      final unsynced = await localDb.getUnsyncedReviewLogs();
      expect(unsynced.length, equals(1));
      expect(unsynced.first.id, equals('log123'));

      await localDb.markReviewLogsSynced(['log123']);
      final remainingUnsynced = await localDb.getUnsyncedReviewLogs();
      expect(remainingUnsynced.isEmpty, isTrue);
    });
  });

  group('UserDataMigrator Tests', () {
    test('Migrates legacy favorites, reviews, and history successfully', () async {
      final localDb = FakeLocalUserDataDataSource();
      final legacyDb = FakeLegacyDbManager(legacyTables: {
        'favorite': [
          OfflineWordRecord(
            slug: '食べる',
            word: '食べる',
            reading: 'たべる',
            added: 1000,
          ),
        ],
        'review': [
          OfflineWordRecord(
            slug: '飲む',
            word: '飲む',
            reading: 'のむ',
            reviews: 3,
            interval: 86400000,
            ease: 2.5,
            due: 2000,
            added: 500,
          ),
        ],
        'history': [
          OfflineWordRecord(
            slug: '猫',
            word: '猫',
            reading: 'ねこ',
            reviews: 5, // Legacy view count stored in reviews
            added: 300,
          ),
        ],
      });

      final migrator = UserDataMigrator(
        localDataSource: localDb,
        legacyDbManager: legacyDb,
      );

      await migrator.migrateLegacyData();

      final favorites = await localDb.getFavorites();
      expect(favorites.length, equals(1));
      expect(favorites.first.word, equals('食べる'));

      final reviewCards = await localDb.getReviewCards();
      expect(reviewCards.length, equals(1));
      expect(reviewCards.first.word, equals('飲む'));
      expect(reviewCards.first.srsData?.reviews, equals(3));

      final history = await localDb.getHistory();
      expect(history.length, equals(1));
      expect(history.first.word, equals('猫'));

      final catViews = await localDb.getViewRecord('猫');
      expect(catViews, isNotNull);
      expect(catViews!.viewCount, equals(5));
    });
  });
}
