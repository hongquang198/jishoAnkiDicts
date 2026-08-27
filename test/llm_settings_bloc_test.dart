import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/features/settings/bloc/llm_settings_bloc.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLlmService extends LlmService {
  List<String> fetchedModelsToReturn = ['gemini-2.0-flash', 'gemini-1.5-pro'];
  int fetchCallCount = 0;
  String? lastApiKeyPassed;

  FakeLlmService({required super.sharedPref});

  @override
  Future<List<String>> fetchAvailableModels({String? apiKey}) async {
    fetchCallCount++;
    lastApiKeyPassed = apiKey;
    return fetchedModelsToReturn;
  }
}

void main() {
  late SharedPreferences prefs;
  late SharedPref sharedPref;
  late FakeLlmService fakeLlmService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    sharedPref = SharedPref(prefs: prefs);
    fakeLlmService = FakeLlmService(sharedPref: sharedPref);
  });

  test('Initial state reflects sharedPref values', () {
    final bloc = LlmSettingsBloc(
      sharedPref: sharedPref,
      llmService: fakeLlmService,
    );

    expect(bloc.state.llmEnabled, isTrue);
    expect(bloc.state.apiKey, equals(''));
    expect(bloc.state.isFetchingModels, isFalse);
    bloc.close();
  });

  test('UpdateApiKeyEvent triggers debounced model fetch when key length >= 20', () async {
    final bloc = LlmSettingsBloc(
      sharedPref: sharedPref,
      llmService: fakeLlmService,
    );

    // Short key should not trigger fetch
    bloc.add(const UpdateApiKeyEvent('short_key'));
    await Future.delayed(const Duration(milliseconds: 700));
    expect(fakeLlmService.fetchCallCount, equals(0));

    // Valid length key (>= 20 chars) should trigger debounced fetch
    bloc.add(const UpdateApiKeyEvent('AIzaSyA1234567890abcdefghijklmnopqrstuvwxyz'));
    
    // Wait for debounce timer (600ms) + async execution
    await Future.delayed(const Duration(milliseconds: 800));

    expect(fakeLlmService.fetchCallCount, equals(1));
    expect(fakeLlmService.lastApiKeyPassed, equals('AIzaSyA1234567890abcdefghijklmnopqrstuvwxyz'));
    expect(bloc.state.availableModels, contains('gemini-2.0-flash'));
    
    bloc.close();
  });
}
