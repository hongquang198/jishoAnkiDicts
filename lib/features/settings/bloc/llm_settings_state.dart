part of 'llm_settings_bloc.dart';

class LlmSettingsState extends Equatable {
  final bool llmEnabled;
  final String apiKey;
  final String modelName;
  final String customPrompt;
  final String effectivePrompt;
  final List<String> availableModels;
  final bool isFetchingModels;
  final String fetchError;

  const LlmSettingsState({
    required this.llmEnabled,
    required this.apiKey,
    required this.modelName,
    required this.customPrompt,
    required this.effectivePrompt,
    required this.availableModels,
    required this.isFetchingModels,
    this.fetchError = '',
  });

  LlmSettingsState copyWith({
    bool? llmEnabled,
    String? apiKey,
    String? modelName,
    String? customPrompt,
    String? effectivePrompt,
    List<String>? availableModels,
    bool? isFetchingModels,
    String? fetchError,
  }) {
    return LlmSettingsState(
      llmEnabled: llmEnabled ?? this.llmEnabled,
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      customPrompt: customPrompt ?? this.customPrompt,
      effectivePrompt: effectivePrompt ?? this.effectivePrompt,
      availableModels: availableModels ?? this.availableModels,
      isFetchingModels: isFetchingModels ?? this.isFetchingModels,
      fetchError: fetchError ?? this.fetchError,
    );
  }

  @override
  List<Object?> get props => [
        llmEnabled,
        apiKey,
        modelName,
        customPrompt,
        effectivePrompt,
        availableModels,
        isFetchingModels,
        fetchError,
      ];
}
