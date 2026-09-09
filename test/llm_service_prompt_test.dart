import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LlmService.buildWordInfoPrompt', () {
    test('requests a memoryTip field alongside tutorComment', () {
      final prompt = LlmService.buildWordInfoPrompt('勉強', 'Vietnamese');

      expect(prompt, contains('"memoryTip"'));
      expect(prompt, contains('"tutorComment"'));
    });

    test('tutorComment requests borrowed word origin and source language information', () {
      final prompt = LlmService.buildWordInfoPrompt('アイスクリーム', 'English');

      expect(
        prompt.toLowerCase(),
        anyOf([
          contains('source language'),
          contains('origin'),
          contains('borrowed'),
          contains('gairaigo'),
        ]),
      );
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

    test('names the target language instead of hard-coding Japanese', () {
      final prompt = LlmService.buildWordInfoPrompt(
        '공부',
        'French',
        targetLanguageName: 'Korean',
      );

      expect(prompt, contains('Korean dictionary data provider'));
      expect(prompt, isNot(contains('Japanese dictionary')));
    });

    test('defaults to the Japanese target lane', () {
      final prompt = LlmService.buildWordInfoPrompt('勉強', 'Vietnamese');

      expect(prompt, contains('Japanese dictionary data provider'));
    });
  });

  group('LlmService.buildPrompt useGenUi identity', () {
    late SharedPref sharedPref;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPref = SharedPref(prefs: await SharedPreferences.getInstance());
      await sharedPref.init();
    });

    test('role names the source/target pair, never bilingual Japanese', () {
      sharedPref.sourceLanguage = 'French';
      sharedPref.targetLanguage = 'Korean';
      final prompt =
          LlmService(sharedPref: sharedPref).buildPrompt('공부', useGenUi: true);

      expect(
        prompt,
        contains('French-speaking Korean dictionary assistant'),
      );
      expect(prompt, isNot(contains('bilingual')));
      expect(prompt, contains('respond ONLY in French'));
    });

    test('kanji guidance only appears for the Japanese target', () {
      sharedPref.sourceLanguage = 'English';
      sharedPref.targetLanguage = 'Japanese';
      final jaPrompt =
          LlmService(sharedPref: sharedPref).buildPrompt('本', useGenUi: true);
      expect(jaPrompt, contains('"KanjiComponents" for'));

      sharedPref.targetLanguage = 'Korean';
      final koPrompt =
          LlmService(sharedPref: sharedPref).buildPrompt('공부', useGenUi: true);
      expect(koPrompt, isNot(contains('"KanjiComponents" for')));
    });
  });
  group('LlmService.buildLeanWordInfoPrompt', () {
    test('keeps tutor content, drops Japanese-only metadata', () {
      final prompt = LlmService.buildLeanWordInfoPrompt(
        '공부',
        'French',
        targetLanguageName: 'Korean',
      );

      expect(prompt, contains('"tutorComment"'));
      expect(prompt, contains('"memoryTip"'));
      expect(prompt, contains('"grammarAnalysis"'));
      expect(prompt, contains('"sentences"'));
      expect(prompt, contains('"tags"'));
      expect(prompt, contains('Korean dictionary data provider'));
      expect(prompt, contains('French'));
      expect(prompt, isNot(contains('hanViet')));
      expect(prompt, isNot(contains('pitchPattern')));
      expect(prompt, isNot(contains('jlpt')));
    });

    test('reading appears only for logographic-script targets', () {
      final korean = LlmService.buildLeanWordInfoPrompt(
        '공부',
        'French',
        targetLanguageName: 'Korean',
      );
      expect(korean, isNot(contains('"reading"')));

      final chinese = LlmService.buildLeanWordInfoPrompt(
        '学习',
        'Vietnamese',
        targetLanguageName: 'Chinese (Simplified)',
      );
      expect(chinese, contains('"reading"'));
    });

    test('sentence keys stay compatible with ExampleSentence parsing', () {
      final prompt = LlmService.buildLeanWordInfoPrompt(
        '공부',
        'French',
        targetLanguageName: 'Korean',
      );

      expect(prompt, contains('"jpSentence"'));
      expect(prompt, contains('"targetSentence"'));
    });

    test('full prompt keeps the Japanese metadata lane', () {
      final prompt = LlmService.buildWordInfoPrompt('勉強', 'Vietnamese');

      expect(prompt, contains('"hanViet"'));
      expect(prompt, contains('"pitchPattern"'));
      expect(prompt, contains('"jlpt"'));
    });
  });
}
