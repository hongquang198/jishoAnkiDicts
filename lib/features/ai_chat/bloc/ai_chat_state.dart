import 'package:equatable/equatable.dart';

class AiChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

class AiChatState extends Equatable {
  final List<AiChatMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? errorMessage;
  final String? initialContext;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.errorMessage,
    this.initialContext,
  });

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    String? errorMessage,
    String? initialContext,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: errorMessage,
      initialContext: initialContext ?? this.initialContext,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        isStreaming,
        errorMessage,
        initialContext,
      ];
}
