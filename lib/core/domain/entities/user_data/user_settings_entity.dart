import 'package:equatable/equatable.dart';

/// Entity representing user configuration and settings.
class UserSettingsEntity extends Equatable {
  final String llmApiKey;
  final String llmModel;
  final String llmCustomPrompt;
  final bool llmEnabled;
  final bool llmGenUiEnabled;
  final String sourceLanguage;
  final String targetLanguage;
  final bool hasCompletedLanguageSetup;
  final int updatedAt;

  const UserSettingsEntity({
    this.llmApiKey = '',
    this.llmModel = 'gemini-2.0-flash',
    this.llmCustomPrompt = '',
    this.llmEnabled = true,
    this.llmGenUiEnabled = true,
    this.sourceLanguage = 'Tiếng Việt',
    this.targetLanguage = 'Japanese',
    this.hasCompletedLanguageSetup = false,
    required this.updatedAt,
  });

  UserSettingsEntity copyWith({
    String? llmApiKey,
    String? llmModel,
    String? llmCustomPrompt,
    bool? llmEnabled,
    bool? llmGenUiEnabled,
    String? sourceLanguage,
    String? targetLanguage,
    bool? hasCompletedLanguageSetup,
    int? updatedAt,
  }) {
    return UserSettingsEntity(
      llmApiKey: llmApiKey ?? this.llmApiKey,
      llmModel: llmModel ?? this.llmModel,
      llmCustomPrompt: llmCustomPrompt ?? this.llmCustomPrompt,
      llmEnabled: llmEnabled ?? this.llmEnabled,
      llmGenUiEnabled: llmGenUiEnabled ?? this.llmGenUiEnabled,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      hasCompletedLanguageSetup:
          hasCompletedLanguageSetup ?? this.hasCompletedLanguageSetup,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'llm_api_key': llmApiKey,
      'llm_model': llmModel,
      'llm_custom_prompt': llmCustomPrompt,
      'llm_enabled': llmEnabled ? 1 : 0,
      'llm_gen_ui_enabled': llmGenUiEnabled ? 1 : 0,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'has_completed_language_setup': hasCompletedLanguageSetup ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  factory UserSettingsEntity.fromMap(Map<String, dynamic> map) {
    return UserSettingsEntity(
      llmApiKey: map['llm_api_key'] as String? ?? '',
      llmModel: map['llm_model'] as String? ?? 'gemini-2.0-flash',
      llmCustomPrompt: map['llm_custom_prompt'] as String? ?? '',
      llmEnabled: map['llm_enabled'] == 1 || map['llm_enabled'] == true,
      llmGenUiEnabled:
          map['llm_gen_ui_enabled'] == 1 || map['llm_gen_ui_enabled'] == true,
      sourceLanguage: map['source_language'] as String? ?? 'Tiếng Việt',
      targetLanguage: map['target_language'] as String? ?? 'Japanese',
      hasCompletedLanguageSetup: map['has_completed_language_setup'] == 1 ||
          map['has_completed_language_setup'] == true,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        llmApiKey,
        llmModel,
        llmCustomPrompt,
        llmEnabled,
        llmGenUiEnabled,
        sourceLanguage,
        targetLanguage,
        hasCompletedLanguageSetup,
        updatedAt,
      ];
}
