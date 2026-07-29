import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/data/datasources/shared_pref.dart';

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

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$key');
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
  String buildPrompt(String query) {
    String template = sharedPref.effectivePrompt;
    return template
        .replaceAll('%search_words%', query)
        .replaceAll('%search_sentence%', query);
  }

  /// Streams the response from Gemini for the given query.
  Stream<String> generateExplanationStream(String query) async* {
    if (!isLlmEnabled) {
      return;
    }

    final apiKey = sharedPref.llmApiKey.trim();
    if (apiKey.isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final prompt = buildPrompt(query);
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
}
