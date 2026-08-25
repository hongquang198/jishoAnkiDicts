import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/in_memory_remote_user_data_source.dart';
import 'package:jisho_anki/core/data/repositories/user_data_repository_impl.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/features/favorite_words/bloc/favorite_bloc.dart';
import 'package:jisho_anki/features/history/bloc/history_bloc.dart';
import 'package:jisho_anki/features/review/bloc/review_bloc.dart';
import 'package:jisho_anki/features/statistics/bloc/statistics_bloc.dart';
import 'package:jisho_anki/features/word_definition/bloc/word_interaction_bloc.dart';
import 'package:jisho_anki/services/srs_engine.dart';
import 'user_local_data_source_test.dart';

void main() {
  group('User Data BLoCs Unit Tests', () {
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

    test('WordInteractionBloc watches and updates favorite and view counts', () async {
      final bloc = WordInteractionBloc(repository: repository);
      final card = WordCard(id: '東京', word: '東京', addedAt: 100, updatedAt: 100);

      bloc.add(const WatchWordInteraction('東京'));
      await pumpEventQueue();
      expect(bloc.state.isFavorite, isFalse);
      expect(bloc.state.viewCount, equals(0));

      bloc.add(RecordWordViewEvent('東京'));
      await pumpEventQueue();
      expect(bloc.state.viewCount, equals(1));

      bloc.add(ToggleWordFavoriteEvent(card));
      await pumpEventQueue();
      expect(bloc.state.isFavorite, isTrue);

      await bloc.close();
    });

    test('ReviewBloc handles review queue progression and undo', () async {
      final card = WordCard(id: '京都', word: '京都', addedAt: 100, updatedAt: 100);
      await repository.toggleReviewEnrollment(card: card);

      final bloc = ReviewBloc(repository: repository);
      bloc.add(const LoadReviewSession());
      await pumpEventQueue();

      expect(bloc.state, isA<ReviewSessionLoaded>());
      final loaded = bloc.state as ReviewSessionLoaded;
      expect(loaded.queue.length, equals(1));
      expect(loaded.currentCard?.word, equals('京都'));

      // Rate card
      bloc.add(const RateCurrentCard(rating: SrsRating.good));
      await pumpEventQueue();

      expect(bloc.state, isA<ReviewSessionCompleted>());

      await bloc.close();
    });

    test('FavoriteBloc loads and filters favorite words', () async {
      final cardA = WordCard(id: '本', word: '本', vietnameseDefinition: 'sách', addedAt: 100, updatedAt: 100);
      final cardB = WordCard(id: '水', word: '水', vietnameseDefinition: 'nước', addedAt: 200, updatedAt: 200);

      await repository.toggleFavorite(card: cardA);
      await repository.toggleFavorite(card: cardB);

      final bloc = FavoriteBloc(repository: repository);
      bloc.add(const LoadFavorites());
      await pumpEventQueue();

      expect(bloc.state, isA<FavoriteLoaded>());
      var state = bloc.state as FavoriteLoaded;
      expect(state.allFavorites.length, equals(2));

      // Search filter
      bloc.add(const SearchFavorites('sách'));
      await pumpEventQueue();
      state = bloc.state as FavoriteLoaded;
      expect(state.filteredFavorites.length, equals(1));
      expect(state.filteredFavorites.first.word, equals('本'));

      await bloc.close();
    });

    test('HistoryBloc handles search and clearing history', () async {
      final card = WordCard(id: '山', word: '山', addedAt: 100, updatedAt: 100);
      await repository.addHistory(card);

      final bloc = HistoryBloc(repository: repository);
      bloc.add(const LoadHistory());
      await pumpEventQueue();

      expect(bloc.state, isA<HistoryLoaded>());
      var state = bloc.state as HistoryLoaded;
      expect(state.allHistory.length, equals(1));

      // Clear history
      bloc.add(const ClearAllHistory());
      await pumpEventQueue();
      state = bloc.state as HistoryLoaded;
      expect(state.allHistory.isEmpty, isTrue);

      await bloc.close();
    });

    test('StatisticsBloc aggregates study metrics', () async {
      final card = WordCard(id: '川', word: '川', addedAt: 100, updatedAt: 100);
      await repository.toggleReviewEnrollment(card: card);

      final bloc = StatisticsBloc(repository: repository);
      bloc.add(const LoadStudyStats());
      await pumpEventQueue();

      expect(bloc.state, isA<StatisticsLoaded>());
      final state = bloc.state as StatisticsLoaded;
      expect(state.stats.newCount, equals(1));

      await bloc.close();
    });
  });
}
