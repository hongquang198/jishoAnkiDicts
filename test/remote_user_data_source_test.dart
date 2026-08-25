import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/firebase_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/in_memory_remote_user_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

void main() {
  group('InMemoryRemoteUserDataDataSource Tests', () {
    late InMemoryRemoteUserDataDataSource remote;

    setUp(() {
      remote = InMemoryRemoteUserDataDataSource(initialUserId: 'user_1');
    });

    test('Initial user ID and anonymous sign-in stream emission', () async {
      expect(remote.currentUserId, equals('user_1'));

      final userFuture = remote.watchUserId().first;
      await remote.signInAnonymously();
      final newUserId = await userFuture;

      expect(newUserId, startsWith('anon_'));
      expect(remote.currentUserId, equals(newUserId));
    });

    test('Push and pull cards updated since timestamp', () async {
      final card1 = WordCard(
        id: '1',
        word: '日',
        addedAt: 1000,
        updatedAt: 1000,
      );
      final card2 = WordCard(
        id: '2',
        word: '月',
        addedAt: 2000,
        updatedAt: 2000,
      );

      await remote.pushCards([card1, card2]);

      final pulledAll = await remote.pullCardsUpdatedSince(500);
      expect(pulledAll.length, equals(2));

      final pulledRecent = await remote.pullCardsUpdatedSince(1500);
      expect(pulledRecent.length, equals(1));
      expect(pulledRecent.first.word, equals('月'));
    });

    test('Push and pull views merges highest view count', () async {
      final view1 = WordViewRecord(
        word: '火',
        viewCount: 3,
        firstViewedAt: 1000,
        lastViewedAt: 3000,
      );
      final view2 = WordViewRecord(
        word: '火',
        viewCount: 5,
        firstViewedAt: 1000,
        lastViewedAt: 5000,
      );

      await remote.pushViews([view1]);
      await remote.pushViews([view2]);

      final views = await remote.pullViews();
      expect(views.length, equals(1));
      expect(views.first.viewCount, equals(5));
    });

    test('Push and pull review logs', () async {
      final log1 = ReviewLog(
        id: 'log1',
        cardId: 'c1',
        rating: SrsRating.again,
        reviewedAt: 1000,
      );
      final log2 = ReviewLog(
        id: 'log2',
        cardId: 'c2',
        rating: SrsRating.good,
        reviewedAt: 3000,
      );

      await remote.pushReviewLogs([log1, log2]);

      final logs = await remote.pullReviewLogs(sinceTimestamp: 2000);
      expect(logs.length, equals(1));
      expect(logs.first.id, equals('log2'));
    });

    test('Delete card removes card from remote', () async {
      final card = WordCard(id: 'c1', word: '水', addedAt: 100, updatedAt: 100);
      await remote.pushCards([card]);

      final before = await remote.pullCardsUpdatedSince(0);
      expect(before.length, equals(1));

      await remote.deleteCard('c1');
      final after = await remote.pullCardsUpdatedSince(0);
      expect(after.isEmpty, isTrue);
    });
  });

  group('FirebaseUserDataDataSource Tests', () {
    test('Firebase data source works with fallback cache', () async {
      final fb = FirebaseUserDataDataSource(initialUserId: 'fb_user_1');
      expect(fb.currentUserId, equals('fb_user_1'));

      final card = WordCard(id: 'fb1', word: '木', addedAt: 100, updatedAt: 100);
      await fb.pushCards([card]);

      final pulled = await fb.pullCardsUpdatedSince(0);
      expect(pulled.length, equals(1));
      expect(pulled.first.word, equals('木'));

      await fb.signInAnonymously();
      expect(fb.currentUserId, startsWith('firebase_anon_'));
    });
  });
}
