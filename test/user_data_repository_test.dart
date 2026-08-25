import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/in_memory_remote_user_data_source.dart';
import 'package:jisho_anki/core/data/repositories/user_data_repository_impl.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/get_favorites_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/get_history_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/record_word_view_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/submit_review_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/toggle_favorite_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/toggle_review_use_case.dart';
import 'package:jisho_anki/services/srs_engine.dart';
import 'user_local_data_source_test.dart';

void main() {
  group('UserDataRepositoryImpl Integration Tests', () {
    late FakeLocalUserDataDataSource localDb;
    late InMemoryRemoteUserDataDataSource remoteDb;
    late UserDataRepositoryImpl repository;

    setUp(() async {
      localDb = FakeLocalUserDataDataSource();
      remoteDb = InMemoryRemoteUserDataDataSource();
      repository = UserDataRepositoryImpl(
        localDataSource: localDb,
        remoteDataSource: remoteDb,
        srsEngine: const SrsEngine(),
      );
      await repository.init();
    });

    test('Toggle favorite updates local store and triggers sync', () async {
      final card = WordCard(
        id: '富士山',
        word: '富士山',
        addedAt: 1000,
        updatedAt: 1000,
      );

      final toggleFavorite = ToggleFavoriteUseCase(repository);
      final getFavorites = GetFavoritesUseCase(repository);

      // 1. Add to favorites
      await toggleFavorite(card);
      var favorites = await getFavorites().first;
      expect(favorites.length, equals(1));
      expect(favorites.first.word, equals('富士山'));
      expect(favorites.first.isFavorite, isTrue);

      // 2. Remove from favorites
      await toggleFavorite(card);
      favorites = await getFavorites().first;
      expect(favorites.isEmpty, isTrue);
    });

    test('Toggle review enrollment enlists card with initial SRS data', () async {
      final card = WordCard(
        id: '桜',
        word: '桜',
        addedAt: 1000,
        updatedAt: 1000,
      );

      final toggleReview = ToggleReviewUseCase(repository);

      await toggleReview(card);
      final enrolled = await repository.getCard('桜');
      expect(enrolled, isNotNull);
      expect(enrolled!.isInReview, isTrue);
      expect(enrolled.srsData?.stage, equals(SrsStage.newCard));

      // Toggle off
      await toggleReview(card);
      final removed = await repository.getCard('桜');
      expect(removed, isNull);
    });

    test('Submit review updates card SRS stage and logs review attempt', () async {
      final card = WordCard(
        id: '空',
        word: '空',
        addedAt: 1000,
        updatedAt: 1000,
      );

      await repository.toggleReviewEnrollment(card: card);
      final enrolledCard = (await repository.getCard('空'))!;

      final submitReview = SubmitReviewUseCase(repository);
      final updated = await submitReview(
        card: enrolledCard,
        rating: SrsRating.good,
      );

      expect(updated.srsData?.stage, equals(SrsStage.learning));
      expect(updated.srsData?.reviews, equals(1));

      final logs = await localDb.getReviewLogs();
      expect(logs.length, equals(1));
      expect(logs.first.cardId, equals('空'));
      expect(logs.first.rating, equals(SrsRating.good));
    });

    test('Record word views and history tracking', () async {
      final recordView = RecordWordViewUseCase(repository);
      await recordView('海');
      await recordView('海');

      final count = await repository.getWordViewCount('海');
      expect(count, equals(2));

      final card = WordCard(id: '海', word: '海', addedAt: 100, updatedAt: 100);
      await repository.addHistory(card);

      final getHistory = GetHistoryUseCase(repository);
      final history = await getHistory().first;
      expect(history.length, equals(1));
      expect(history.first.word, equals('海'));
    });
  });
}
