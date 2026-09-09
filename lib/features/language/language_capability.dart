/// Per-target-language feature gates.
///
/// Japanese-only affordances (pitch accent, kanji components, Han-Viet
/// readings, JLPT tags, Jisho senses) have no meaning for other language
/// pairs. Call sites must consult these flags instead of hard-coding
/// `targetLanguage == 'Japanese'` or branching on the app UI locale.
class LanguageCapability {
  final String targetLanguage;
  const LanguageCapability(this.targetLanguage);

  /// True when the target language uses Japanese-specific offline lanes.
  bool get isJapanese {
    final normalized = targetLanguage.trim().toLowerCase();
    return normalized == 'japanese' || normalized == 'ja' || normalized == 'jp';
  }

  /// True for logographic-script targets whose written form does not tell
  /// you how to say the word (Japanese, Chinese). Phonetic-script targets
  /// (Vietnamese, Korean, French, …) need no reading field.
  bool get isChinese {
    final normalized = targetLanguage.trim().toLowerCase();
    return normalized == 'chinese' ||
        normalized == 'chinese (simplified)' ||
        normalized == 'chinese (traditional)' ||
        normalized == 'mandarin' ||
        normalized == 'zh' ||
        normalized == '中文';
  }

  /// Whether lookups should carry a pronunciation/reading field.
  bool get needsReading => isJapanese || isChinese;

  bool get supportsPitch => isJapanese;
  bool get supportsKanjiComponents => isJapanese || isChinese;
  bool get supportsHanViet => isJapanese;
  bool get supportsJlpt => isJapanese;
  bool get supportsJishoSenses => isJapanese;

  /// Offline gloss lane (jpvnDictionary) only exists for Japanese headwords.
  bool get supportsOfflineGloss => isJapanese;
}
