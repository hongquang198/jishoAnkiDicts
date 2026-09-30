import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/llm_service.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final LlmService llmService;
  String _initialContext = '';

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
      _initialContext = event.initialContext;
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
    if (event.text.trim().isEmpty) return;

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

      final answer = await llmService.sendChatMessage(
        initialContext: _initialContext,
        history: [
          for (final m in updatedMessages)
            (isUser: m.isUser, text: m.text),
        ],
        text: event.text,
      );
      updatedMessages[assistantMessageIndex] = AiChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
          messages: List.from(updatedMessages), isStreaming: false));
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
