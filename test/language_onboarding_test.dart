import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Language Preferences and Onboarding Tests', () {
    late SharedPreferences prefs;
    late SharedPref sharedPref;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      sharedPref = SharedPref(prefs: prefs);
      await sharedPref.init();
    });

    test('Default language setup values', () {
      expect(sharedPref.sourceLanguage, equals('Tiếng Việt'));
      expect(sharedPref.targetLanguage, equals('Japanese'));
      expect(sharedPref.hasCompletedLanguageSetup, isFalse);
    });

    test('Persists updated language and onboarding completion', () {
      sharedPref.sourceLanguage = 'English';
      sharedPref.targetLanguage = 'Japanese';
      sharedPref.hasCompletedLanguageSetup = true;

      expect(sharedPref.sourceLanguage, equals('English'));
      expect(sharedPref.targetLanguage, equals('Japanese'));
      expect(sharedPref.hasCompletedLanguageSetup, isTrue);
    });
  });
}
