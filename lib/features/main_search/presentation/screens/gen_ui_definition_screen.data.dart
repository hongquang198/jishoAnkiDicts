part of 'gen_ui_definition_screen.dart';

/// Local-lane data wiring for [GenUiDefinitionScreen].
///
/// Resolves bloc-held dictionary data, attaches to the pre-warmed lanes, and
/// derives the effective display values (local data preferred, LLM gap-fill
/// otherwise). Streaming lifecycle lives in `.streaming.dart`, view
/// recording in `.view_record.dart`.
extension _GenUiDefinitionDataExt on _GenUiDefinitionScreenState {
  void _resolveBlocData() {
    final resolved = resolveMainSearchData(
      widget.args.mainSearchBloc,
      currentJapaneseWord,
    );
    _jishoDefinition = resolved.jishoDefinition;
    _hanViet = resolved.hanViet;
  }

  /// Attaches to the pre-warmed lanes for this query (started by the
  /// search-result tile when it appeared). When missing — e.g. deep link —
  /// starts them fresh through the same wiring. Every future reference is
  /// assigned exactly once so streamed rebuilds never replay animations.
  void _attachDataPrefetch() {
    final query = currentJapaneseWord;
    final cache = getIt<GenUiDataPrefetchCache>();
    var prefetch = cache.get(query);
    if (prefetch == null) {
      final fresh = startDefaultDataPrefetch(
        query: query,
        jishoDefinition: _jishoDefinition,
      );
      cache.warm(query, start: () => fresh);
      prefetch = fresh;
    }

    _kanjiListFuture = prefetch.kanjiComponents;
    prefetch.pitchWidgets.then((widgets) {
      if (!mounted) return;
      _update(() {
        _pitchWidgets = widgets;
        _pitchLaneDone = true;
      });
    });
    prefetch.examples.then((examples) {
      if (!mounted) return;
      _update(() {
        _examples = examples;
        _examplesFuture = Future<List<ExampleSentence>>.value(examples);
      });
    });
    prefetch.wordInfo.then((info) {
      if (!mounted) return;
      _update(() {
        _wordInfoPending = false;
        if (info == null || info['found'] != true) return;
        _llmInfo = info;
        final comment = _llmString('tutorComment');
        if (comment.isNotEmpty) _aiTutorComment = comment;
        final grammar = _llmString('grammarAnalysis');
        if (grammar.isNotEmpty) _grammarAnalysis = grammar;
        final memoryTip = _llmString('memoryTip');
        if (memoryTip.isNotEmpty) _memoryTip = memoryTip;
        // Swap the examples future only when the local list was empty and
        // the LLM actually provided sentences, so animations replay once.
        if ((_examples?.isEmpty ?? true) && _effectiveExamples.isNotEmpty) {
          _examplesFuture =
              Future<List<ExampleSentence>>.value(_effectiveExamples);
        }
      });
      _recordBaseView(info);
    });
    prefetch.image.then((picture) {
      if (!mounted || picture == null) return;
      _update(() => _descriptivePicture = picture);
    });
  }

  // --- Effective values (local data preferred over LLM gap-fill) ---

  String get _effectiveReading {
    final reading = _jishoDefinition.reading;
    if (reading != null && reading.isNotEmpty) return reading;
    return _llmString('reading');
  }

  List<String> get _effectiveHanViet =>
      _hanViet.isNotEmpty ? _hanViet : _llmStringList('hanViet');

  /// Headword shown in the app bar and header. Follows the same precedence
  /// as [canonicalBaseForm] (LLM lemma, then jisho) but falls back to the
  /// typed query instead of empty, so sentence lookups still show context.
  /// Recomputes on every build, so the display swaps to the base form as
  /// soon as the LLM lane lands (no extra wiring: `_llmInfo` arrives via
  /// `_update`, which already triggers a rebuild).
  String get _effectiveHeadword {
    if (_llmInfo?['found'] == true) {
      final llmWord = _llmString('word');
      if (llmWord.isNotEmpty) return llmWord;
    }
    final headword = _jishoDefinition.headword.trim();
    if (headword.isNotEmpty) return headword;
    return currentJapaneseWord;
  }

  List<Widget> get _effectivePitchWidgets {
    if (_pitchWidgets.isNotEmpty) return _pitchWidgets;
    final pattern = _llmString('pitchPattern');
    final reading = _effectiveReading;
    if (pattern.isEmpty || reading.isEmpty) return const [];
    return KanjiHelper.buildPitchWidgets(
        reading: reading, pitchPattern: pattern);
  }

  List<ExampleSentence> get _effectiveExamples {
    final local = _examples;
    if (local != null && local.isNotEmpty) return local;
    final raw = _llmInfo?['sentences'];
    if (raw is! List) return const [];
    return raw.map((item) {
      final map = item is Map<String, dynamic>
          ? item
          : (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      return ExampleSentence(
        jpSentence: map['jpSentence']?.toString() ?? '',
        targetSentence: map['targetSentence']?.toString() ?? '',
      );
    }).toList();
  }

  bool get _hasTagData =>
      _jishoDefinition.slug.isNotEmpty ||
      _llmInfo?['found'] == true ||
      _llmStringList('jlpt').isNotEmpty ||
      _llmStringList('tags').isNotEmpty;

  String _llmString(String key) =>
      _llmInfo?[key]?.toString().trim().isNotEmpty == true
          ? _llmInfo![key].toString()
          : '';

  List<String> _llmStringList(String key) {
    final value = _llmInfo?[key];
    return value is List ? value.map((e) => e.toString()).toList() : const [];
  }
}
