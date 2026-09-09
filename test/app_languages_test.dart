import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/core/error/failures.dart';
import 'package:jisho_anki/features/language/app_languages.dart';
import 'package:jisho_anki/features/language/language_capability.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/features/main_search/domain/repositories/jisho_repository.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_grammar_point.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_han_viet_reading.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_localized_gloss.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/search_jisho_for_phrase.dart';
import 'package:jisho_anki/features/main_search/presentation/bloc/main_search_bloc.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/models/grammar_point.dart';
import 'package:jisho_anki/models/localized_gloss.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_jisho_api/api.dart';

void main() {
  group('AppLanguage registry', () {
    test('covers the legacy stored labels', () {
      expect(sourceLanguageByLabel('Tiếng Việt').code, equals('vi'));
      expect(sourceLanguageByLabel('English').code, equals('en'));
      expect(kTargetLanguages, contains('Japanese'));
    });

    test('unknown source label falls back to English', () {
      final fallback = sourceLanguageByLabel('Klingon');
      expect(fallback.code, equals('en'));
      expect(fallback.promptName, equals('English'));
    });

    test('locale follows source, non-vi/en sources use English UI', () {
      expect(localeCodeForSource('Tiếng Việt'), equals('vi'));
      expect(localeCodeForSource('English'), equals('en'));
      expect(localeCodeForSource('French'), equals('en'));
      expect(localeCodeForSource('Klingon'), equals('en'));
    });

    test('prompt names resolve per source', () {
      expect(promptNameForSource('Tiếng Việt'), equals('Vietnamese'));
      expect(promptNameForSource('English'), equals('English'));
      expect(promptNameForSource('French'), equals('French'));
    });

    test('target capability gates Japanese-only lanes', () {
      expect(LanguageCapability('Japanese').supportsOfflineGloss, isTrue);
      expect(LanguageCapability('Japanese').supportsJishoSenses, isTrue);
      for (final target in ['Korean', 'English', 'French']) {
        expect(LanguageCapability(target).supportsOfflineGloss, isFalse);
        expect(LanguageCapability(target).supportsJishoSenses, isFalse);
      }
    });

    test('reading is only needed for logographic scripts', () {
      for (final target in ['Japanese', 'ja', 'Chinese (Simplified)', 'zh']) {
        expect(LanguageCapability(target).needsReading, isTrue,
            reason: target);
      }
      for (final target in ['Korean', 'Vietnamese', 'English', 'French']) {
        expect(LanguageCapability(target).needsReading, isFalse,
            reason: target);
      }
    });
  });

  group('SharedPref language derivation', () {
    late SharedPref sharedPref;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPref = SharedPref(prefs: await SharedPreferences.getInstance());
      await sharedPref.init();
    });

    test('defaults stay Vietnamese source and Japanese target', () {
      expect(sharedPref.sourceLanguage, equals('Tiếng Việt'));
      expect(sharedPref.targetLanguage, equals('Japanese'));
      expect(sharedPref.appLocaleCode, equals('vi'));
      expect(sharedPref.isAppInVietnamese, isTrue);
      expect(sharedPref.appLanguageName, equals('Vietnamese'));
      expect(sharedPref.sourceLanguageCode, equals('vi'));
      expect(sharedPref.targetLanguageCapability.supportsOfflineGloss, isTrue);
    });

    test('locale and prompts follow the source language', () {
      sharedPref.sourceLanguage = 'French';
      expect(sharedPref.appLocaleCode, equals('en'));
      expect(sharedPref.isAppInVietnamese, isFalse);
      expect(sharedPref.appLanguageName, equals('French'));
      expect(sharedPref.sourceLanguageCode, equals('fr'));
    });

    test('capability follows the target language', () {
      sharedPref.targetLanguage = 'Korean';
      expect(sharedPref.targetLanguageCapability.supportsOfflineGloss, isFalse);
      expect(sharedPref.targetLanguageCapability.supportsJishoSenses, isFalse);
    });

    test('default prompt is one template in the source language', () {
      sharedPref.sourceLanguage = 'Tiếng Việt';
      expect(sharedPref.activeDefaultPrompt, contains('in Vietnamese'));
      sharedPref.sourceLanguage = 'English';
      expect(sharedPref.activeDefaultPrompt, contains('in English'));
      expect(
        SharedPref.defaultPromptFor('French'),
        contains('in French'),
      );
    });

    test('custom prompt still wins over the default', () {
      sharedPref.sourceLanguage = 'French';
      sharedPref.llmCustomPrompt = 'custom %search_words%';
      expect(sharedPref.effectivePrompt, equals('custom %search_words%'));
    });
  });

  group('MainSearchBloc lane gating', () {
    late SharedPref sharedPref;
    late _FakeSearchJisho searchJisho;
    late _FakeGlossLookup glossLookup;
    late _FakeGrammar grammarLookup;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPref = SharedPref(prefs: await SharedPreferences.getInstance());
      await sharedPref.init();
      getIt.registerSingleton<SharedPref>(sharedPref);
      searchJisho = _FakeSearchJisho();
      glossLookup = _FakeGlossLookup();
      grammarLookup = _FakeGrammar();
    });

    tearDown(() async {
      if (getIt.isRegistered<SharedPref>()) {
        getIt.unregister<SharedPref>();
      }
    });

    Future<void> search() async {
      final bloc = MainSearchBloc(
        searchJishoForPhrase: searchJisho,
        lookUpLocalizedGloss: glossLookup,
        lookupHanVietReading: _FakeHanViet(),
        lookupGrammarPoint: grammarLookup,
      );
      bloc.add(const SearchForPhraseEvent('本'));
      await Future.delayed(const Duration(milliseconds: 100));
      await bloc.close();
    }

    test('Vietnamese source with Japanese target runs all lanes', () async {
      sharedPref.sourceLanguage = 'Tiếng Việt';
      sharedPref.targetLanguage = 'Japanese';
      await search();
      expect(glossLookup.calls, equals(1));
      expect(searchJisho.calls, equals(1));
    });

    test('English source with Japanese target skips the VI gloss lane',
        () async {
      sharedPref.sourceLanguage = 'English';
      sharedPref.targetLanguage = 'Japanese';
      await search();
      expect(glossLookup.calls, equals(0));
      expect(searchJisho.calls, equals(1));
    });

    test('non-Japanese target leaves lookup to the LLM lane', () async {
      sharedPref.sourceLanguage = 'English';
      sharedPref.targetLanguage = 'Korean';
      await search();
      expect(glossLookup.calls, equals(0));
      expect(searchJisho.calls, equals(0));
      expect(grammarLookup.calls, greaterThanOrEqualTo(1));
    });
  });
}

class _FakeSearchJisho extends SearchJishoForPhrase {
  int calls = 0;

  _FakeSearchJisho() : super(_FakeJishoRepository());

  @override
  Future<Either<Failure, List<JishoDefinition>>> call(String phrase) async {
    calls++;
    return const Right([]);
  }
}

class _FakeJishoRepository implements JishoRepository {
  @override
  Future<Either<Failure, JishoAPIResult>> searchForPhrase(
      {required String phrase}) {
    throw UnimplementedError();
  }
}

class _FakeGlossLookup extends LookUpLocalizedGloss {
  int calls = 0;

  @override
  Future<Either<Failure, List<LocalizedGloss>>> call(String phrase) async {
    calls++;
    return const Right([]);
  }
}

class _FakeHanViet extends LookupHanVietReading {
  @override
  Future<Either<Failure, List<String>>> call(String params) async {
    return const Right([]);
  }
}

class _FakeGrammar extends LookUpGrammarPoint {
  int calls = 0;

  @override
  Future<Either<Failure, List<GrammarPoint>>> call(String params) async {
    calls++;
    return const Right([]);
  }
}
