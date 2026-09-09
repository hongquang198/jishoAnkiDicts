import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/data/datasources/shared_pref.dart';
import '../features/language/language_capability.dart';
import 'package:jisho_anki/services/llm/genui_catalog.dart';

class LlmService {
  final SharedPref sharedPref;

  LlmService({required this.sharedPref});

  bool get isApiKeyConfigured => sharedPref.llmApiKey.trim().isNotEmpty;
  bool get isLlmEnabled => sharedPref.llmEnable;

  /// Dynamically queries Gemini API to fetch all available models that support generateContent.
  Future<List<String>> fetchAvailableModels({String? apiKey}) async {
    final key = (apiKey ?? sharedPref.llmApiKey).trim();
    if (key.isEmpty) {
      return [];
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$key');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final modelsList = json['models'] as List<dynamic>? ?? [];

      final List<String> available = [];
      for (final item in modelsList) {
        final methods = (item['supportedGenerationMethods'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (methods.contains('generateContent')) {
          String name = item['name'] as String? ?? '';
          if (name.startsWith('models/')) {
            name = name.substring('models/'.length);
          }
          if (name.isNotEmpty) {
            available.add(name);
          }
        }
      }
      return available;
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMsg = errorJson['error']?['message'] ?? response.body;
      throw Exception('API error (${response.statusCode}): $errorMsg');
    }
  }

  /// Formats the prompt template replacing `%search_words%` and `%search_sentence%`
  /// with the provided query string.
  ///
  /// When [useGenUi] is true the A2UI protocol prompt is used instead of the
  /// custom prompt defined in settings.
  String buildPrompt(String query, {bool useGenUi = false}) {
    if (useGenUi) {
      final catalogSchema = const JsonEncoder.withIndent('  ')
          .convert(genUiCatalog.toCapabilitiesJson());
      final sourceLanguage = sharedPref.appLanguageName;
      final targetName = sharedPref.targetLanguage;
      // Kanji breakdowns only mean something for a Japanese target.
      final componentChoice = sharedPref
              .targetLanguageCapability
              .supportsKanjiComponents
          ? '("DefinitionCard" for words, phrases or grammar points, '
              '"ExampleSentences" for example sentences, "KanjiComponents" for '
              'kanji breakdown).'
          : '("DefinitionCard" for words, phrases or grammar points, '
              '"ExampleSentences" for example sentences).';
      return 'You are a $sourceLanguage-speaking $targetName dictionary assistant. '
          'Analyze the query: "$query".\n\n'
          'Respond by generating a UI card via the A2UI protocol. Your entire '
          'response MUST be exactly ONE fenced JSON code block and nothing '
          'else, using EXACTLY this envelope:\n'
          '```json\n'
          '{\n'
          '  "version": "v0.9",\n'
          '  "updateComponents": {\n'
          '    "surfaceId": "llm_definition_surface",\n'
          '    "components": [\n'
          '      {\n'
          '        "id": "root",\n'
          '        "component": "<ComponentName>",\n'
          '        "<property>": "<value>"\n'
          '      }\n'
          '    ]\n'
          '  }\n'
          '}\n'
          '```\n\n'
          'Strict rules:\n'
          '- "version" MUST be the exact string "v0.9".\n'
          '- "surfaceId" MUST be the exact string "llm_definition_surface".\n'
          '- "catalogId" is not needed.\n'
          '- There must be exactly one component and its "id" MUST be "root".\n'
          '- All property values must be inline literals (strings, lists, '
          'objects). Never use {"path": ...} references.\n'
          '- Do not output any text outside the JSON code block and do not '
          'wrap it in another object.\n\n'
          'Available components (name -> property schema):\n'
          '$catalogSchema\n\n'
          'Language weight: respond ONLY in $sourceLanguage. One request, '
          'one language — NEVER emit multiple languages. Fill the matching '
          'definition property fully; keep the other to a 1-gloss fallback.\n\n'
          'Choose the single most appropriate component for the query '
          '$componentChoice\n'
          'DefinitionCard rules: closest meaning first, no tutor commentary '
          'or mnemonics (commentary lives in other cards). Field-level '
          'detail follows each property description in the schema above.\n'
          '- Example root component:\n'
          '{"id": "root", "component": "DefinitionCard", '
          '"localizedGloss": "<closest $sourceLanguage gloss> — '
          '<1-line nuance>; also: <secondary gloss>", '
          '"senses": [{"english_definitions": ["<closest gloss>", '
          '"<near synonym>"], "parts_of_speech": ["Noun"], "tags": [], '
          '"info": ["<when to use this sense>"]}]}';
    }
    String template = sharedPref.effectivePrompt;
    return template
        .replaceAll('%search_words%', query)
        .replaceAll('%search_sentence%', query);
  }

  /// Streams the response from Gemini for the given query.
  ///
  /// Pass [useGenUi] to stream the A2UI protocol response instead of the
  /// custom prompt defined in settings.
  Stream<String> generateExplanationStream(
    String query, {
    bool useGenUi = false,
  }) async* {
    if (!isLlmEnabled) {
      return;
    }

    final apiKey = sharedPref.llmApiKey.trim();
    if (apiKey.isEmpty) {
      throw Exception(
          'API Key is missing. Please set your Gemini API key in Settings.');
    }

    final prompt = buildPrompt(query, useGenUi: useGenUi);
    final selectedModel = sharedPref.llmModel;
    final model = GenerativeModel(
      model: selectedModel,
      apiKey: apiKey,
    );

    final content = [Content.text(prompt)];
    final responseStream = model.generateContentStream(content);

    await for (final chunk in responseStream) {
      if (chunk.text != null && chunk.text!.isNotEmpty) {
        yield chunk.text!;
      }
    }
  }

  /// Adds `startChatSession({required String initialContext})` method in `LlmService`.
  ChatSession startChatSession({required String initialContext}) {
    final apiKey = sharedPref.llmApiKey.trim();
    if (apiKey.isEmpty) {
      throw Exception(
          'API Key is missing. Please set your Gemini API key in Settings.');
    }
    final selectedModel = sharedPref.llmModel;
    final model = GenerativeModel(
      model: selectedModel,
      apiKey: apiKey,
    );
    final sourceLanguage = sharedPref.appLanguageName;
    final targetName = sharedPref.targetLanguage;
    return model.startChat(
      history: [
        Content.text(
            'System Context / Background for this chat session:\n$initialContext\n\n'
            'You are an expert $targetName dictionary and language tutor AI. '
            'Explain in $sourceLanguage. '
            'Help the user understand vocabulary, grammar, nuances, and etymology.')
      ],
    );
  }

  /// Fetches dictionary metadata (reading, han viet, pitch accent pattern,
  /// example sentences, jisho tags), an image search term and an AI-tutor
  /// comment for a word as structured JSON. The image term is resolved
  /// against Wikimedia Commons by [WikimediaImageService]; model-provided
  /// URLs are never rendered.
  ///
  /// This is the Japanese-lane gap-fill tool: pitch, Han-Viet and JLPT only
  /// exist for Japanese, so non-Japanese targets leave those fields empty
  /// while the tutor comment, memory tip and translated sentences still come
  /// back in the source language.
  ///
  /// Builds the structured word-info prompt for [fetchWordInfo].
  ///
  /// Static and injectable-free so tests can assert on the exact contract
  /// (field names, conditional rules) without mocking Gemini.
  static String buildWordInfoPrompt(
    String query,
    String sourceLanguage, {
    String targetLanguageName = 'Japanese',
  }) {
    return 'You are a $targetLanguageName dictionary data provider. For the query '
        '"$query", return ONLY a JSON object (no markdown fences, no '
        'commentary) with exactly this shape:\n'
        '{\n'
        '  "found": <bool - whether the query is a valid $targetLanguageName word or phrase>,\n'
        '  "word": "<canonical $targetLanguageName word form>",\n'
        '  "reading": "<hiragana reading>",\n'
        '  "hanViet": ["<one Sino-Vietnamese reading per kanji character>"],\n'
        '  "isCommon": <bool>,\n'
        '  "tags": ["<word category tags>"],\n'
        '  "jlpt": ["<JLPT level(s), e.g. N4>"],\n'
        '  "pitchPattern": "<string of L/H characters exactly one longer than the reading, e.g. LHHH>",\n'
        '  "imageQuery": "<simple English noun phrase describing what the word looks like, for an image search, e.g. \'cherry blossom\'>",\n'
        '  "tutorComment": "<2-4 sentences from an AI tutor: whether this word is worth memorizing (common vs rare), its register/formality, practical usage guidance and common mistakes. If the word is a loanword/borrowed word (Gairaigo) or has notable etymological origins, explicitly include the source language and original word/meaning directly here>",\n'
        '  "memoryTip": "<a vivid mnemonic or memory trick (kanji story, sound-alike, visual image) to remember this word/phrase - ONLY if it is genuinely worth memorizing, otherwise empty string>",\n'
        '  "grammarAnalysis": "<Detailed grammar analysis, sentence breakdown, particle explanation, and syntactic structure if the query is a sentence, phrase, or grammar pattern, or empty string if it is a single word>",\n'
        '  "sentences": [{"jpSentence": "<Japanese sentence>", "targetSentence": "<$sourceLanguage translation>"}]\n'
        '}\n\n'
        'Rules:\n'
        '- "pitchPattern" describes the pitch accent: L = low, H = high, one '
        'character per mora of the reading plus one trailing character.\n'
        '- "grammarAnalysis" must provide a clear, structured breakdown of grammar points, clause structure, and particle usage if the query is a sentence or phrase (written in $sourceLanguage); leave empty if a simple word.\n'
        '- "sentences" must contain 2-3 natural example sentences using the word.\n'
        '- "tutorComment" must be written in $sourceLanguage, and if the word is a borrowed word or loanword (Gairaigo), explicitly include its source language and original form.\n'
        '- "memoryTip" must be written in $sourceLanguage and stay under ~40 '
        'words; judge worth-memorizing by frequency and practical usefulness '
        '(skip it for rare or highly transparent words).\n'
        '- Use empty arrays or empty strings for anything unknown. '
        'Set "found" to false if the query is not $targetLanguageName.';
  }

  /// Lean gap-fill prompt for non-Japanese targets: tutor content, memory
  /// tip, grammar analysis and translated sentences in the source language,
  /// without the Japanese-only metadata (pitch, Han-Viet, JLPT, tags).
  ///
  /// The `sentences` items keep the established `jpSentence`/`targetSentence`
  /// keys so [ExampleSentence] parsing stays untouched: `jpSentence` holds
  /// the sentence in the target language, `targetSentence` its translation.
  static String buildLeanWordInfoPrompt(
    String query,
    String sourceLanguage, {
    required String targetLanguageName,
  }) {
    // Word-category tags travel across languages; a pronunciation guide only
    // matters for logographic scripts (Vietnamese is read as written).
    final readingLine =
        LanguageCapability(targetLanguageName).needsReading
            ? '  "reading": "<pronunciation guide in the target language\'s script, or empty string>",\n'
            : '';
    return 'You are a $targetLanguageName dictionary data provider. For the query '
        '"$query", return ONLY a JSON object (no markdown fences, no '
        'commentary) with exactly this shape:\n'
        '{\n'
        '  "found": <bool - whether the query is a valid $targetLanguageName word or phrase>,\n'
        '  "word": "<canonical $targetLanguageName word form>",\n'
        '$readingLine'
        '  "isCommon": <bool>,\n'
        '  "tags": ["<word category tags, e.g. Noun, Verb Transitive>"],\n'
        '  "imageQuery": "<simple English noun phrase describing what the word looks like, for an image search, e.g. \'cherry blossom\'>",\n'
        '  "tutorComment": "<2-4 sentences from an AI tutor: whether this word is worth memorizing (common vs rare), its register/formality, practical usage guidance and common mistakes. If the word is a loanword/borrowed word or has notable etymological origins, explicitly include the source language and original word/meaning directly here>",\n'
        '  "memoryTip": "<a vivid mnemonic or memory trick to remember this word/phrase - ONLY if it is genuinely worth memorizing, otherwise empty string>",\n'
        '  "grammarAnalysis": "<Detailed grammar analysis, sentence breakdown, and syntactic structure if the query is a sentence, phrase, or grammar pattern (written in $sourceLanguage), or empty string if it is a single word>",\n'
        '  "sentences": [{"jpSentence": "<example sentence in $targetLanguageName>", "targetSentence": "<$sourceLanguage translation>"}]\n'
        '}\n\n'
        'Rules:\n'
        '- "sentences" must contain 2-3 natural example sentences using the word.\n'
        '- "tutorComment" must be written in $sourceLanguage.\n'
        '- "memoryTip" must be written in $sourceLanguage and stay under ~40 '
        'words; judge worth-memorizing by frequency and practical usefulness '
        '(skip it for rare or highly transparent words).\n'
        '- Use empty arrays or empty strings for anything unknown. '
        'Set "found" to false if the query is not $targetLanguageName.';
  }

  Future<Map<String, dynamic>?> fetchWordInfo(String query) async {
    if (!isLlmEnabled || query.trim().isEmpty) return null;
    final apiKey = sharedPref.llmApiKey.trim();
    if (apiKey.isEmpty) return null;

    final sourceLanguage = sharedPref.appLanguageName;
    final targetName = sharedPref.targetLanguage;
    // Japanese unlocks the full metadata lane; other targets get the lean
    // lane so the model is never asked for pitch/Han-Viet/JLPT.
    final prompt =
        sharedPref.targetLanguageCapability.supportsOfflineGloss
            ? buildWordInfoPrompt(
              query,
              sourceLanguage,
              targetLanguageName: targetName,
            )
            : buildLeanWordInfoPrompt(
              query,
              sourceLanguage,
              targetLanguageName: targetName,
            );

    try {
      final model = GenerativeModel(
        model: sharedPref.llmModel,
        apiKey: apiKey,
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.trim().isEmpty) return null;
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }
}
