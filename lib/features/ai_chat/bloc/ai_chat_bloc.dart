import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../services/llm_service.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final LlmService llmService;
  ChatSession? _chatSession;

  AiChatBloc({required this.llmService}) : super(const AiChatState()) {
    on<InitializeAiChat>(_onInitializeAiChat);
    on<SendChatMessage>(_onSendChatMessage);
    on<SelectPromptSuggestion>(_onSelectPromptSuggestion);
  }

  Future<void> _onInitializeAiChat(
    InitializeAiChat event,
    Emitter<AiChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, initialContext: event.initialContext));
    try {
      _chatSession =
          llmService.startChatSession(initialContext: event.initialContext);
      emit(state.copyWith(
        isLoading: false,
        messages: [
          AiChatMessage(
            text:
                'Hello! I am your AI Japanese Tutor. How can I help you master this word, grammar point, or concept today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<AiChatState> emit,
  ) async {
    if (event.text.trim().isEmpty || _chatSession == null) return;

    final userMessage = AiChatMessage(
      text: event.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<AiChatMessage>.from(state.messages)
      ..add(userMessage);
    emit(state.copyWith(
        messages: updatedMessages, isStreaming: true, errorMessage: null));

    try {
      final assistantMessageIndex = updatedMessages.length;
      final assistantPlaceholder = AiChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      );
      updatedMessages.add(assistantPlaceholder);
      emit(state.copyWith(messages: List.from(updatedMessages)));

      final responseStream =
          _chatSession!.sendMessageStream(Content.text(event.text));
      String accumulated = '';

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          accumulated += chunk.text!;
          updatedMessages[assistantMessageIndex] = AiChatMessage(
            text: accumulated,
            isUser: false,
            timestamp: DateTime.now(),
          );
          emit(state.copyWith(messages: List.from(updatedMessages)));
        }
      }

      emit(state.copyWith(isStreaming: false));
    } catch (e) {
      emit(state.copyWith(
        isStreaming: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSelectPromptSuggestion(
    SelectPromptSuggestion event,
    Emitter<AiChatState> emit,
  ) async {
    add(SendChatMessage(text: event.chipText));
  }
}
