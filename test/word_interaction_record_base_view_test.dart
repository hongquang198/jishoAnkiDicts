import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/in_memory_remote_user_data_source.dart';
import 'package:jisho_anki/core/data/repositories/user_data_repository_impl.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/features/word_definition/bloc/word_interaction_bloc.dart';
import 'package:jisho_anki/services/srs_engine.dart';
import 'user_local_data_source_test.dart';

void main() {
  group('WordInteractionBloc RecordBaseViewEvent', () {
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

    WordCard surfaceCard() => WordCard(
          id: '食べた',
          word: '食べた',
          addedAt: 100,
          updatedAt: 100,
        );

    test('inflected surface records the view under the LLM base form',
        () async {
      final bloc = WordInteractionBloc(repository: repository);

      bloc.add(RecordBaseViewEvent(
        card: surfaceCard(),
        query: '食べた',
        wordInfo: {'found': true, 'word': '食べる'},
      ));
      await pumpEventQueue();

      expect(await repository.getWordViewCount('食べる'), equals(1));
      expect(await repository.getWordViewCount('食べた'), equals(0));
      final history = await repository.watchHistory().first;
      expect(history.map((c) => c.id), contains('食べる'));
      // The bloc re-watches the lemma so the counter follows the base form.
      expect(bloc.state.word, equals('食べる'));
      expect(bloc.state.viewCount, equals(1));

      await bloc.close();
    });

    test('falls back to the jisho base when the LLM lane is unavailable',
        () async {
      final bloc = WordInteractionBloc(repository: repository);

      bloc.add(RecordBaseViewEvent(
        card: surfaceCard(),
        query: '食べた',
        jishoDefinition: JishoDefinition(slug: '食べる'),
      ));
      await pumpEventQueue();

      expect(await repository.getWordViewCount('食べる'), equals(1));

      await bloc.close();
    });

    test('sentence queries record nothing', () async {
      final bloc = WordInteractionBloc(repository: repository);

      bloc.add(RecordBaseViewEvent(
        card: surfaceCard(),
        query: '今日はとても暑いですね。',
        wordInfo: {'found': true, 'word': '今日はとても暑いですね。'},
      ));
      await pumpEventQueue();

      expect(await repository.getWordViewCount('今日はとても暑いですね。'), equals(0));
      expect(await repository.watchHistory().first, isEmpty);

      await bloc.close();
    });
  });
}
