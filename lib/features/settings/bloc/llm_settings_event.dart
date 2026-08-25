part of 'llm_settings_bloc.dart';

abstract class LlmSettingsEvent extends Equatable {
  const LlmSettingsEvent();

  @override
  List<Object?> get props => [];
}

class ToggleLlmEnabledEvent extends LlmSettingsEvent {
  final bool enabled;
  const ToggleLlmEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleLlmGenUiEnabledEvent extends LlmSettingsEvent {
  final bool enabled;
  const ToggleLlmGenUiEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateApiKeyEvent extends LlmSettingsEvent {
  final String apiKey;
  const UpdateApiKeyEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateModelNameEvent extends LlmSettingsEvent {
  final String modelName;
  const UpdateModelNameEvent(this.modelName);

  @override
  List<Object?> get props => [modelName];
}

class UpdateCustomPromptEvent extends LlmSettingsEvent {
  final String prompt;
  const UpdateCustomPromptEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

class ResetPromptToDefaultEvent extends LlmSettingsEvent {
  const ResetPromptToDefaultEvent();
}

class FetchAvailableModelsEvent extends LlmSettingsEvent {
  final String? apiKey;
  const FetchAvailableModelsEvent({this.apiKey});

  @override
  List<Object?> get props => [apiKey];
}
