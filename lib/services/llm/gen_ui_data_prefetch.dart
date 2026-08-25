import 'package:flutter/material.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/models/example_sentence.dart';
import 'package:jisho_anki/models/kanji.dart';
import 'package:jisho_anki/services/preloaded_image.dart';

/// Thumbnail width requested from Wikimedia during prewarm; the render box is
/// ~120 logical px so 320 device px keeps the transfer small (~1/3 the pixels
/// of the 600 px default) while staying sharp on high-DPR screens.
const int kPrewarmThumbnailWidth = 320;

/// Decode bound passed to [preloadImage]; covers a 120 logical px box up to
/// DPR 2 without wasting memory.
const int kPrewarmDecodeWidth = 240;

/// Eagerly-started data lanes for one query, resolved while the search-result
/// tile is still visible so that opening the GenUI screen paints badges,
/// examples, picture and tutor comment without any loading spinners.
///
/// Every lane is best-effort: failures resolve to null/empty values instead of
/// propagating, so one broken source never blocks the screen.
class GenUiDataPrefetch {
  GenUiDataPrefetch({
    required this.wordInfo,
    required this.image,
    required this.pitchWidgets,
    required this.examples,
    required this.kanjiComponents,
  });

  /// Structured gap-fill payload ([LlmService.fetchWordInfo]): tutorComment,
  /// imageQuery, isCommon/tags/jlpt and sentences fallbacks. Null when the LLM
  /// is disabled or the call failed.
  final Future<Map<String, dynamic>?> wordInfo;

  /// Descriptive picture with bytes already downloaded AND decoded into
  /// Flutter's image cache. Null on any miss.
  final Future<PreloadedImage?> image;

  /// Local-database lanes (always available without an API key).
  final Future<List<Widget>> pitchWidgets;
  final Future<List<ExampleSentence>> examples;
  final Future<List<Kanji>> kanjiComponents;

  /// Starts every lane immediately. All workers are injectable for tests; a
  /// null worker resolves that lane to an empty result.
  ///
  /// Image staging per design §5: search with the best LOCAL term first
  /// (first English sense of [jishoDefinition], else [query]); on a hit,
  /// return before ever awaiting [fetchWordInfo]. On a miss, upgrade exactly
  /// once with the model's `imageQuery` term once it lands.
  factory GenUiDataPrefetch.start({
    required String query,
    required JishoDefinition jishoDefinition,
    bool llmEnabled = false,
    Future<Map<String, dynamic>?> Function(String query)? fetchWordInfo,
    Future<String?> Function(String searchTerm)? searchThumbnailUrl,
    Future<PreloadedImage?> Function(String url)? loadImage,
    Future<List<Widget>> Function()? loadPitchWidgets,
    Future<List<ExampleSentence>> Function()? loadExamples,
    Future<List<Kanji>> Function()? loadKanjiComponents,
  }) {
    final localTerm = (jishoDefinition.slug.isNotEmpty
            ? jishoDefinition.slug
            : (jishoDefinition.word?.isNotEmpty == true
                ? jishoDefinition.word!
                : query))
        .trim();

    final wordInfoFuture = () async {
      if (!llmEnabled || fetchWordInfo == null) return null;
      try {
        return await fetchWordInfo(query);
      } catch (_) {
        return null;
      }
    }();

    Future<String?> safeSearch(
      Future<String?> Function(String searchTerm) searcher,
      String term,
    ) async {
      try {
        return await searcher(term);
      } catch (_) {
        return null;
      }
    }

    final imageFuture = () async {
      final searcher = searchThumbnailUrl;
      if (searcher == null) return null;
      final load = loadImage ?? ((url) => preloadImage(url: url));

      final stage1Url = await safeSearch(searcher, localTerm);
      PreloadedImage? stage1;
      if (stage1Url != null && stage1Url.isNotEmpty) {
        stage1 = await load(stage1Url);
      }
      // Hit: keep it and skip the wordInfo wait entirely.
      if (stage1 != null) return stage1;

      final info = await wordInfoFuture;
      final llmTerm = info?['imageQuery']?.toString().trim() ?? '';
      if (llmTerm.isEmpty || llmTerm == localTerm) return stage1;
      final stage2Url = await safeSearch(searcher, llmTerm);
      if (stage2Url == null || stage2Url.isEmpty) return stage1;
      return load(stage2Url);
    }();

    Future<List<T>> guarded<T>(Future<List<T>> Function()? loader) async {
      if (loader == null) return const [];
      try {
        return await loader();
      } catch (_) {
        return const [];
      }
    }

    return GenUiDataPrefetch(
      wordInfo: wordInfoFuture,
      image: imageFuture,
      pitchWidgets: guarded(loadPitchWidgets),
      examples: guarded(loadExamples),
      kanjiComponents: guarded(loadKanjiComponents),
    );
  }
}

/// Bounded cache of in-flight/completed [GenUiDataPrefetch]s keyed by query.
///
/// Registered as a lazy singleton in `injection.dart` — resolve via
/// `getIt<GenUiDataPrefetchCache>()`. Mirrors [GenUiPrefetchCache]'s FIFO=8
/// policy; unlike streams, futures cannot be cancelled, so eviction simply
/// drops references and lets in-flight lanes finish harmlessly.
class GenUiDataPrefetchCache {
  GenUiDataPrefetchCache();

  final Map<String, GenUiDataPrefetch> _entries = {};
  static const int _maxEntries = 8;

  /// Starts prefetching [query] unless an entry already exists.
  ///
  /// [start] is only invoked when a new entry is created.
  void warm(String query, {required GenUiDataPrefetch Function() start}) {
    final key = query.trim();
    if (key.isEmpty || _entries.containsKey(key)) return;
    _evictIfNeeded();
    _entries[key] = start();
  }

  GenUiDataPrefetch? get(String query) => _entries[query.trim()];

  /// Removes the entry for [query], if present. In-flight lanes are left to
  /// complete (futures are not cancellable); only the reference is dropped.
  void invalidate(String query) {
    _entries.remove(query.trim());
  }

  void _evictIfNeeded() {
    while (_entries.length >= _maxEntries) {
      final oldestKey = _entries.keys.first;
      _entries.remove(oldestKey);
    }
  }
}
