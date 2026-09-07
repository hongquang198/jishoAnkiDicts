part of 'definition_screen.dart';

/// State data wiring for [DefinitionScreen].
///
/// Resolves the headword from args, loads the local dictionary futures, and
/// attaches to the shared prefetch lanes. Pure UI-state orchestration: the
/// business decision of what counts as a view lives in [WordInteractionBloc].
extension _DefinitionScreenDataExt on _DefinitionScreenState {
  void _resolveArgs() {
    jishoDefinition = widget.args.jishoDefinition ?? JishoDefinition(slug: '');
    vnDefinition = widget.args.vnDefinition ?? VietnameseDefinition();
    currentJapaneseWord = vnDefinition.word;
    if (currentJapaneseWord.isEmpty) {
      currentJapaneseWord = jishoDefinition.word ?? '';
    }
    if (currentJapaneseWord.isEmpty) {
      currentJapaneseWord = jishoDefinition.slug;
    }
  }

  void _loadLocalFutures() {
    // VN-DB words have no jisho entry (empty stub): fall back to the VN
    // headword so the pitch lookup still has an orthography key.
    final vnWord = vnDefinition.word;
    final lookupWord = jishoDefinition.word?.isNotEmpty == true
        ? jishoDefinition.word
        : (vnWord.isNotEmpty ? vnWord : null);
    final lookupSlug = jishoDefinition.slug.isNotEmpty
        ? jishoDefinition.slug
        : (vnWord.isNotEmpty ? vnWord : jishoDefinition.slug);
    pitchAccent = KanjiHelper.getPitchAccent(
      word: lookupWord,
      slug: lookupSlug,
      reading: jishoDefinition.reading,
      context: context,
    );

    kanjiList = KanjiHelper.getKanjiComponent(word: currentJapaneseWord);

    try {
      final lang = getIt<SharedPref>().prefs.getString('language');
      if (lang?.contains('English') == true) {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'englishExampleDictionary');
      } else if (lang == 'Tiếng Việt') {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'exampleDictionary');
      }
    } catch (e) {
      log('Error getting example sentence $e');
    }
  }

  void _attachDataPrefetch() {
    final query = currentJapaneseWord;
    final cache = getIt<GenUiDataPrefetchCache>();
    var prefetch = cache.get(query);
    if (prefetch == null) {
      final fresh = startDefaultDataPrefetch(
        query: query,
        jishoDefinition: jishoDefinition,
      );
      cache.warm(query, start: () => fresh);
      prefetch = fresh;
    }

    prefetch.wordInfo.then((info) {
      if (!mounted) return;
      _update(() {
        _isAiLoading = false;
        if (info != null && info['found'] == true) {
          final comment = info['tutorComment']?.toString().trim() ?? '';
          if (comment.isNotEmpty) _aiTutorComment = comment;
          final memoryTip = info['memoryTip']?.toString().trim() ?? '';
          if (memoryTip.isNotEmpty) _aiMemoryTip = memoryTip;
          final grammar = info['grammarAnalysis']?.toString().trim() ?? '';
          if (grammar.isNotEmpty) _aiGrammarAnalysis = grammar;
        }
      });
    });
    prefetch.image.then((picture) {
      if (!mounted || picture == null) return;
      _update(() => _descriptivePicture = picture);
    });
  }
}
