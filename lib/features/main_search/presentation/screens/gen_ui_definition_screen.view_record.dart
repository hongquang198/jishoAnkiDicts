part of 'gen_ui_definition_screen.dart';

/// View/history recording for [GenUiDefinitionScreen].
///
/// Dispatches [RecordBaseViewEvent] so the base-form resolution and the
/// repository writes live in [WordInteractionBloc]. Uses the bloc instance
/// captured at init (safe to touch from `dispose`, unlike `context.read`).
extension _GenUiDefinitionViewRecordExt on _GenUiDefinitionScreenState {
  /// Records the view against the dictionary base form, never the inflected
  /// surface. Sentence queries resolve to empty and are skipped entirely
  /// (ephemeral AI explanation: no view, no history).
  void _recordBaseView(Map<String, dynamic>? info) {
    if (_viewRecorded) return;
    final query = currentJapaneseWord;
    if (query.isEmpty || isSentenceQuery(query)) return;
    _viewRecorded = true;
    _interactionBloc.add(RecordBaseViewEvent(
      card: _surfaceCard(info),
      query: query,
      wordInfo: info,
      jishoDefinition: _jishoDefinition,
    ));
  }

  WordCard _surfaceCard(Map<String, dynamic>? info) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return WordCard(
      id: currentJapaneseWord,
      word: currentJapaneseWord,
      slug: _jishoDefinition.slug.isNotEmpty
          ? _jishoDefinition.slug
          : currentJapaneseWord,
      reading: _effectiveReading,
      isCommon:
          (_jishoDefinition.isCommon || info?['isCommon'] == true) ? 1 : 0,
      tags: _jishoDefinition.tags.isNotEmpty
          ? _jishoDefinition.tags
          : _llmStringList('tags'),
      jlpt: _jishoDefinition.jlpt.isNotEmpty
          ? _jishoDefinition.jlpt
          : _llmStringList('jlpt'),
      addedAt: now,
      updatedAt: now,
    );
  }
}
