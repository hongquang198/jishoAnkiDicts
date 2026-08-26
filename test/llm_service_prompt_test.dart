import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/services/llm_service.dart';

void main() {
  group('LlmService.buildWordInfoPrompt', () {
    test('requests a memoryTip field alongside tutorComment', () {
      final prompt = LlmService.buildWordInfoPrompt('勉強', 'Vietnamese');

      expect(prompt, contains('"memoryTip"'));
      expect(prompt, contains('"tutorComment"'));
    });

    test('memoryTip is conditional on the word being worth memorizing', () {
      final prompt = LlmService.buildWordInfoPrompt('勉強', 'English');

      expect(
        prompt.toLowerCase(),
        contains('worth'),
        reason: 'prompt must tell the model to only fill memoryTip when the '
            'word/phrase is worth memorizing',
      );
    });

    test('substitutes the query and target language', () {
      final prompt = LlmService.buildWordInfoPrompt('頑張る', 'Vietnamese');

      expect(prompt, contains('頑張る'));
      expect(prompt, contains('Vietnamese'));
    });
  });
}
