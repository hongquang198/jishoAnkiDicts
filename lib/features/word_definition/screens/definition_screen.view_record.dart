part of 'definition_screen.dart';

/// View/history recording for [DefinitionScreen].
///
/// Dispatches [RecordBaseViewEvent] so the base-form resolution and the
/// repository writes live in [WordInteractionBloc]. The screen only decides
/// *when* to record (immediately without LLM, on the LLM lane otherwise with
/// a delayed local fallback) and re-watches the bloc on the resolved base so
/// the counter follows the lemma.
extension _DefinitionScreenViewRecordExt on _DefinitionScreenState {
  WordCard _createWordCard() {
    return WordCard(
      id: currentJapaneseWord,
      word: jishoDefinition.word ?? currentJapaneseWord,
      slug: jishoDefinition.slug,
      reading: jishoDefinition.reading ?? '',
      isCommon: jishoDefinition.isCommon ? 1 : 0,
      tags: jishoDefinition.tags,
      jlpt: jishoDefinition.jlpt,
      senses: jishoDefinition.senses,
      localizedGloss: localizedGloss.gloss,
      glossLang: getIt<SharedPref>().sourceLanguageCode,
      addedAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _recordViewByBase() {
    final query = currentJapaneseWord;
    if (query.isEmpty || isSentenceQuery(query)) return;
    final sharedPref = getIt<SharedPref>();
    final llmActive =
        sharedPref.llmEnable && sharedPref.llmApiKey.trim().isNotEmpty;
    if (!llmActive) {
      _dispatchBaseRecord(null);
      return;
    }
    getIt<GenUiDataPrefetchCache>().get(query)?.wordInfo.then((info) {
      if (!mounted || _historyRecorded) return;
      _dispatchBaseRecord(info);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted || _historyRecorded) return;
      _dispatchBaseRecord(null);
    });
  }

  void _dispatchBaseRecord(Map<String, dynamic>? info) {
    if (_historyRecorded) return;
    _historyRecorded = true;
    context.read<WordInteractionBloc>().add(RecordBaseViewEvent(
          card: _createWordCard(),
          query: currentJapaneseWord,
          wordInfo: info,
          jishoDefinition:
              widget.args.jishoDefinition != null ? jishoDefinition : null,
          vnWord: localizedGloss.headword,
        ));
  }
}
