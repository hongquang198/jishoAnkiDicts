import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/models/example_sentence.dart';
import 'package:jisho_anki/services/llm/gen_ui_data_prefetch.dart';
import 'package:jisho_anki/services/preloaded_image.dart';
import 'package:unofficial_jisho_api/api.dart';

GenUiDataPrefetch _fakePrefetch() => GenUiDataPrefetch(
      wordInfo: Future.value(null),
      image: Future.value(null),
      pitchWidgets: Future.value(const []),
      examples: Future.value(const []),
      kanjiComponents: Future.value(const []),
    );

JishoDefinition _definitionWithSense(String englishTerm) => JishoDefinition(
      slug: 'sakura',
      senses: [
        JishoWordSense(englishDefinitions: [englishTerm], partsOfSpeech: [])
      ],
    );

void main() {
  group('GenUiDataPrefetchCache', () {
    test('warm is idempotent per trimmed query', () {
      final cache = GenUiDataPrefetchCache();
      var starts = 0;
      cache.warm(' sakura ', start: () {
        starts++;
        return _fakePrefetch();
      });
      cache.warm('sakura', start: () {
        starts++;
        return _fakePrefetch();
      });
      expect(starts, 1);
      expect(cache.get('SAKURA'.toLowerCase()), isNotNull);
    });

    test('warm ignores blank queries', () {
      final cache = GenUiDataPrefetchCache();
      cache.warm('   ', start: _fakePrefetch);
      expect(cache.get(''), isNull);
    });

    test('evicts the oldest entry beyond 8 entries', () {
      final cache = GenUiDataPrefetchCache();
      for (var i = 0; i < 8; i++) {
        cache.warm('q$i', start: _fakePrefetch);
      }
      cache.warm('q8', start: _fakePrefetch);
      expect(cache.get('q0'), isNull);
      expect(cache.get('q1'), isNotNull);
      expect(cache.get('q8'), isNotNull);
    });
  });

  group('GenUiDataPrefetch.start lanes', () {
    test('LLM-gated lane stays cold when disabled', () async {
      var called = false;
      final prefetch = GenUiDataPrefetch.start(
        query: 'sakura',
        jishoDefinition: _definitionWithSense('cherry blossom'),
        llmEnabled: false,
        fetchWordInfo: (_) async {
          called = true;
          return {'found': true};
        },
      );
      expect(await prefetch.wordInfo, isNull);
      expect(called, isFalse);
    });

    test('one failing lane does not fail the others', () async {
      final prefetch = GenUiDataPrefetch.start(
        query: 'sakura',
        jishoDefinition: _definitionWithSense('cherry blossom'),
        llmEnabled: true,
        fetchWordInfo: (_) async => throw Exception('llm down'),
        searchThumbnailUrl: (_) async => 'https://example.com/a.png',
        loadImage: (url) async =>
            PreloadedImage(url: url, provider: MemoryImage(Uint8List(0))),
        loadPitchWidgets: () async => throw Exception('db down'),
        loadExamples: () async =>
            [ExampleSentence(jpSentence: 'jp', targetSentence: 'en')],
        loadKanjiComponents: () async => throw Exception('db down'),
      );
      expect(await prefetch.wordInfo, isNull);
      expect((await prefetch.image)?.url, 'https://example.com/a.png');
      expect(await prefetch.pitchWidgets, isEmpty);
      expect(await prefetch.examples, hasLength(1));
      expect(await prefetch.kanjiComponents, isEmpty);
    });
  });

  group('GenUiDataPrefetch.start image staging', () {
    late List<String> searchedTerms;

    setUp(() {
      searchedTerms = [];
    });

    GenUiDataPrefetch buildPrefetch({
      required String localHitUrl,
      required Map<String, dynamic>? Function() onWordInfo,
      String Function(String term)? onSecondSearch,
    }) {
      var searches = 0;
      return GenUiDataPrefetch.start(
        query: '\u685c',
        jishoDefinition: _definitionWithSense('cherry blossom'),
        llmEnabled: true,
        fetchWordInfo: (_) async => onWordInfo(),
        searchThumbnailUrl: (term) async {
          searchedTerms.add(term);
          searches++;
          if (searches == 1) return localHitUrl;
          return onSecondSearch?.call(term);
        },
        loadImage: (url) async =>
            PreloadedImage(url: url, provider: MemoryImage(Uint8List(0))),
      );
    }

    test('local-term hit short-circuits without waiting for wordInfo',
        () async {
      final pending = Completer<Map<String, dynamic>?>();
      final prefetch = GenUiDataPrefetch.start(
        query: '\u685c',
        jishoDefinition: _definitionWithSense('cherry blossom'),
        llmEnabled: true,
        fetchWordInfo: (_) => pending.future,
        searchThumbnailUrl: (term) async {
          searchedTerms.add(term);
          return 'https://example.com/local.png';
        },
        loadImage: (url) async =>
            PreloadedImage(url: url, provider: MemoryImage(Uint8List(0))),
      );
      final image = await prefetch.image;
      expect(image?.url, 'https://example.com/local.png');
      expect(searchedTerms, ['cherry blossom']);
      await Future<void>.delayed(Duration.zero);
      expect(pending.isCompleted, isFalse);
    });

    test('local-term miss upgrades to the LLM term exactly once', () async {
      var wordInfoCalls = 0;
      final prefetch = buildPrefetch(
        localHitUrl: '',
        onWordInfo: () {
          wordInfoCalls++;
          return {'found': true, 'imageQuery': ' sakura tree '};
        },
        onSecondSearch: (term) => 'https://example.com/upgraded.png',
      );
      final image = await prefetch.image;
      expect(wordInfoCalls, 1);
      expect(searchedTerms, ['cherry blossom', 'sakura tree']);
      expect(image?.url, 'https://example.com/upgraded.png');
    });

    test('no upgrade when the LLM term is empty or matches locally',
        () async {
      final prefetch = buildPrefetch(
        localHitUrl: '',
        onWordInfo: () => {'found': true, 'imageQuery': ''},
      );
      expect(await prefetch.image, isNull);
      expect(searchedTerms, ['cherry blossom']);

      searchedTerms.clear();
      final prefetch2 = buildPrefetch(
        localHitUrl: '',
        onWordInfo: () => {'found': true, 'imageQuery': 'cherry blossom'},
      );
      expect(await prefetch2.image, isNull);
      expect(searchedTerms, ['cherry blossom']);
    });
  });
}
