import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/features/ai_chat/bloc/ai_chat_bloc.dart';
import 'package:jisho_anki/features/ai_chat/bloc/ai_chat_state.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLlmService extends LlmService {
  FakeLlmService()
      : super(sharedPref: SharedPref(prefs: MockSharedPreferences()));

  @override
  ChatSession startChatSession({required String initialContext}) {
    throw UnimplementedError();
  }
}

class MockSharedPreferences implements SharedPreferences {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AiChatBloc Tests', () {
    test('initial state is AiChatState', () {
      final bloc = AiChatBloc(llmService: FakeLlmService());
      expect(bloc.state, const AiChatState());
      bloc.close();
    });
  });
}
