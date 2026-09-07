import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';

/// Sentence-ending / splitting punctuation in Japanese and English.
const _sentencePunctuation = {'。', '、', '？', '！', '?', '!'};

/// Particles that strongly suggest a multi-word utterance when the query is
/// long enough. Single words (even inflected verbs like 食べさせられたくなかった)
/// never contain these as particles.
const _particles = {'は', 'が', 'を', 'に', 'へ', 'と', 'も', 'から', 'まで'};

/// Whether [query] is a sentence/phrase rather than a single word lookup.
///
/// Sentences get ephemeral AI explanations only: no view count, no history.
/// Single words (including inflected verbs/adjectives) return false so their
/// view is counted against the base form via [canonicalBaseForm].
bool isSentenceQuery(String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.split('').any(_sentencePunctuation.contains)) return true;
  if (trimmed.contains(RegExp(r'\s'))) {
    final tokens = trimmed.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (tokens.length >= 2 && trimmed.length >= 6) return true;
  }
  if (trimmed.length >= 6 &&
      _particles.any((p) => trimmed.contains(p))) {
    return true;
  }
  return false;
}

/// Canonical key views/history are recorded under.
///
/// - Sentence queries resolve to `''` (caller must skip recording).
/// - The LLM canonical `word` wins when `found == true`: this is the base
///   form for inflected surfaces (食べた -> 食べる).
/// - Falls back to the jisho base, then the trimmed query.
String canonicalBaseForm({
  required String query,
  Map<String, dynamic>? wordInfo,
  JishoDefinition? jishoDefinition,
  String? vnWord,
}) {
  if (isSentenceQuery(query)) return '';
  final llmWord = wordInfo?['word']?.toString().trim() ?? '';
  if (wordInfo?['found'] == true && llmWord.isNotEmpty) return llmWord;
  final jishoWord = jishoDefinition?.japaneseWord.trim() ?? '';
  if (jishoWord.isNotEmpty) return jishoWord;
  final vn = vnWord?.trim() ?? '';
  if (vn.isNotEmpty) return vn;
  return query.trim();
}
