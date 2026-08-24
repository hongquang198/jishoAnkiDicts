import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
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
        home: GenUiDefinitionScreen(
          args: GenUiDefinitionScreenArgs(query: '\u685c'),
        ),
      ),
    );
    // Flush lane completions and let each resulting setState rebuild.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('common word'), findsOneWidget);
    // DefinitionTags pads each tag with spaces.
    expect(find.text(' N4 '), findsOneWidget);
    expect(find.textContaining('Worth memorizing'), findsOneWidget);
  });
}
