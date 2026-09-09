/// Central language registry for the source/target pair the user picks in
/// onboarding (and later edits in settings).
///
/// The source (native) language drives the app locale, the LLM prompt
/// language, and the language saved cards are glossed in. The target
/// (learning) language drives [LanguageCapability]: Japanese unlocks the
/// offline/Jisho lanes, every other target is served by the LLM/GenUI lane
/// (model responses are language-agnostic, so any target is allowed).
///
/// Stored pref values are the display [AppLanguage.label]s, so the legacy
/// `'Tiếng Việt'` / `'English'` / `'Japanese'` values keep working.
class AppLanguage {
  /// Stable code used for `gloss_lang` and [LocalizedGloss.langCode].
  final String code;

  /// Display label; this is what onboarding/settings persist.
  final String label;

  /// Name used inside LLM prompts (e.g. `Vietnamese`, `French`).
  final String promptName;

  const AppLanguage({
    required this.code,
    required this.label,
    required this.promptName,
  });
}

/// App UI (locale + hardcoded strings) only exists for Vietnamese and
/// English; every other source falls back to the English UI while prompts
/// and glosses still use the real source language.
String localeCodeForSource(String label) =>
    sourceLanguageByLabel(label).code == 'vi' ? 'vi' : 'en';

/// Native languages offered as the translation source.
const List<AppLanguage> kSourceLanguages = [
  AppLanguage(code: 'vi', label: 'Tiếng Việt', promptName: 'Vietnamese'),
  AppLanguage(code: 'en', label: 'English', promptName: 'English'),
  AppLanguage(code: 'fr', label: 'French', promptName: 'French'),
  AppLanguage(code: 'de', label: 'German', promptName: 'German'),
  AppLanguage(code: 'es', label: 'Spanish', promptName: 'Spanish'),
  AppLanguage(code: 'ko', label: 'Korean', promptName: 'Korean'),
  AppLanguage(code: 'zh', label: 'Chinese (Simplified)', promptName: 'Chinese'),
  AppLanguage(code: 'ja', label: 'Japanese', promptName: 'Japanese'),
  AppLanguage(code: 'th', label: 'Thai', promptName: 'Thai'),
  AppLanguage(code: 'id', label: 'Indonesian', promptName: 'Indonesian'),
];

/// Learning languages offered as the lookup target. Anything goes: the
/// LLM/GenUI lane serves non-Japanese targets, so this list can grow freely.
const List<String> kTargetLanguages = [
  'Japanese',
  'English',
  'Vietnamese',
  'Korean',
  'Chinese (Simplified)',
  'French',
  'German',
  'Spanish',
  'Thai',
  'Indonesian',
];

const AppLanguage _fallbackSource = AppLanguage(
  code: 'en',
  label: 'English',
  promptName: 'English',
);

/// Resolves a stored source label, falling back to English for unknown
/// (e.g. hand-edited) values so callers never branch on raw strings.
AppLanguage sourceLanguageByLabel(String label) {
  for (final language in kSourceLanguages) {
    if (language.label == label) return language;
  }
  return _fallbackSource;
}

/// Display labels for the source dropdowns.
List<String> get sourceLanguageLabels =>
    kSourceLanguages.map((language) => language.label).toList();

/// Prompt name for [label] (e.g. `Vietnamese` for `Tiếng Việt`).
String promptNameForSource(String label) =>
    sourceLanguageByLabel(label).promptName;

/// Stable code for [label] (e.g. `vi`), persisted as `gloss_lang`.
String codeForSource(String label) => sourceLanguageByLabel(label).code;
