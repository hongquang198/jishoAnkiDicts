import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAiChat extends AiChatEvent {
  final String initialContext;

  const InitializeAiChat({required this.initialContext});

  @override
  List<Object?> get props => [initialContext];
}

class SendChatMessage extends AiChatEvent {
  final String text;

  const SendChatMessage({required this.text});

  @override
  List<Object?> get props => [text];
}

class SelectPromptSuggestion extends AiChatEvent {
  final String chipText;

  const SelectPromptSuggestion({required this.chipText});

  @override
  List<Object?> get props => [chipText];
}
