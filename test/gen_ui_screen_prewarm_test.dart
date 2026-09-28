import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/features/word_definition/bloc/word_interaction_bloc.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/features/main_search/presentation/screens/gen_ui_definition_screen.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/services/llm/gen_ui_data_prefetch.dart';
import 'package:jisho_anki/services/llm/gen_ui_prefetch.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:jisho_anki/services/preloaded_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_jisho_api/api.dart';

const _png1x1 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
    'DwAChwGA60e6kgAAAABJRU5ErkJggg==';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Hand-rolled fake: the screen only needs a living WordInteractionBloc for
  // view/favorite events, never real persistence. Empty streams + no-op
  // futures keep these widget tests hermetic (no sqflite, no GetIt wiring).
  WordInteractionBloc bloc() =>
      WordInteractionBloc(repository: _FakeUserDataRepository());

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'llmEnable': false,
      'language': 'English',
    });
    final prefs = await SharedPreferences.getInstance();
    final sharedPref = SharedPref(prefs: prefs);
    await sharedPref.init();
    getIt
      ..registerSingleton<SharedPref>(sharedPref)
      ..registerSingleton<LlmService>(
          LlmService(sharedPref: getIt<SharedPref>()))
      ..registerLazySingleton<GenUiPrefetchCache>(() => GenUiPrefetchCache());
    // Deliberately NOT registered: WikimediaImageService / Dictionary /
    // GenUiDataPrefetchCache fresh-start services. If the screen issued any
    // fresh call during attach instead of using the warmed entry below,
    // getIt would throw and fail this test.
  });

  testWidgets(
      'screen renders prewarmed lanes without issuing new service calls',
      (tester) async {
    final pictureProvider = MemoryImage(base64Decode(_png1x1));
    final prefetch = GenUiDataPrefetch.start(
      query: '\u685c',
      jishoDefinition: JishoDefinition(
        slug: '\u685c',
        senses: [
          JishoWordSense(
              englishDefinitions: ['cherry blossom'], partsOfSpeech: [])
        ],
      ),
      llmEnabled: true,
      fetchWordInfo: (_) async => <String, dynamic>{
        'found': true,
        'isCommon': true,
        'tags': <String>['noun'],
        'jlpt': <String>['N4'],
        'tutorComment': 'Worth memorizing: common in daily conversation.',
        'imageQuery': 'cherry blossom',
      },
      searchThumbnailUrl: (_) async => throw StateError('must not search'),
      loadImage: (url) async =>
          PreloadedImage(url: url, provider: pictureProvider),
      loadPitchWidgets: () async => const [],
      loadExamples: () async => const [],
      loadKanjiComponents: () async => const [],
    );

    final dataCache = GenUiDataPrefetchCache();
    dataCache.warm('\u685c', start: () => prefetch);
    getIt.registerLazySingleton<GenUiDataPrefetchCache>(() => dataCache);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<WordInteractionBloc>(
          create: (_) => bloc(),
          child: GenUiDefinitionScreen(
            args: GenUiDefinitionScreenArgs(query: '桜'),
          ),
        ),
      ),
    );
    // Flush lane completions and let each resulting setState rebuild.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('common'), findsOneWidget);
    // DefinitionTags renders raw tag text (padding is visual EdgeInsets).
    expect(find.text('N4'), findsOneWidget);
    expect(find.textContaining('Worth memorizing'), findsOneWidget);
  });

  testWidgets(
      'GenUiDefinitionScreen renders grammar analysis for sentence queries',
      (tester) async {
    final prefetch = GenUiDataPrefetch.start(
      query: '雨が降っている',
      jishoDefinition: JishoDefinition(slug: '雨が降っている'),
      llmEnabled: true,
      fetchWordInfo: (_) async => <String, dynamic>{
        'found': true,
        'grammarAnalysis': 'Present continuous tense using verb ている.',
        'tutorComment': 'Common descriptive phrase.',
      },
      searchThumbnailUrl: (_) async => null,
      loadImage: (_) async => null,
      loadPitchWidgets: () async => const [],
      loadExamples: () async => const [],
      loadKanjiComponents: () async => const [],
    );

    final dataCache = GenUiDataPrefetchCache();
    dataCache.warm('雨が降っている', start: () => prefetch);
    if (getIt.isRegistered<GenUiDataPrefetchCache>()) {
      getIt.unregister<GenUiDataPrefetchCache>();
    }
    getIt.registerLazySingleton<GenUiDataPrefetchCache>(() => dataCache);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<WordInteractionBloc>(
          create: (_) => bloc(),
          child: GenUiDefinitionScreen(
            args: GenUiDefinitionScreenArgs(query: '雨が降っている'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    // The grammar section is AiGrammarBreakdownCard (l10n title), not a
    // literal 'Grammar Analysis' header — that string exists nowhere anymore.
    expect(find.text('Grammar & Structure Breakdown'), findsOneWidget);
    expect(find.textContaining('Present continuous tense'), findsOneWidget);
    // Tutor card title is 'AI Tutor Insights' ('AI Tutor Notes' renders nowhere).
    expect(find.text('AI Tutor Insights'), findsOneWidget);
  });
}

class _FakeUserDataRepository implements UserDataRepository {
  @override
  Stream<List<WordCard>> watchAllCards() => Stream.value([]);

  @override
  Stream<List<WordCard>> watchFavorites() => Stream.value([]);

  @override
  Stream<List<WordCard>> watchReviewCards() => Stream.value([]);

  @override
  Stream<Map<String, WordViewRecord>> watchWordViews() =>
      Stream.value(const {});

  @override
  Stream<List<WordCard>> watchHistory() => Stream.value([]);

  @override
  Future<WordCard?> getCard(String id) async => null;

  @override
  Future<void> saveCard(WordCard card) async {}

  @override
  Future<void> deleteCard(String id) async {}

  @override
  Future<void> toggleFavorite({required WordCard card}) async {}

  @override
  Future<void> toggleReviewEnrollment({required WordCard card}) async {}

  @override
  Future<WordCard> submitReview({
    required WordCard card,
    required SrsRating rating,
    int durationMs = 0,
  }) async =>
      card;

  @override
  Future<void> revertReview({
    required WordCard previousCardState,
    required String logIdToDelete,
  }) async {}

  @override
  Future<void> recordWordView(String word) async {}

  @override
  Future<int> getWordViewCount(String word) async => 0;

  @override
  Future<void> addHistory(WordCard card) async {}

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> removeHistory(String id) async {}

  @override
  Future<UserStudyStats> getStudyStats() async => const UserStudyStats();

  @override
  Future<void> syncWithRemote() async {}
}
