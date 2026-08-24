import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/data/datasources/shared_pref.dart';
import '../../../services/llm_service.dart';

part 'llm_settings_event.dart';
part 'llm_settings_state.dart';

class LlmSettingsBloc extends Bloc<LlmSettingsEvent, LlmSettingsState> {
  final SharedPref sharedPref;
  final LlmService llmService;

  LlmSettingsBloc({
    required this.sharedPref,
    required this.llmService,
  }) : super(LlmSettingsState(
          llmEnabled: sharedPref.llmEnable,
          llmGenUiEnabled: sharedPref.llmGenUiEnable,
          apiKey: sharedPref.llmApiKey,
          modelName: sharedPref.llmModel,
          customPrompt: sharedPref.llmCustomPrompt,
          effectivePrompt: sharedPref.effectivePrompt,
          availableModels: const [],
          isFetchingModels: false,
        )) {
    on<ToggleLlmEnabledEvent>(_onToggleLlmEnabled);
    on<ToggleLlmGenUiEnabledEvent>(_onToggleLlmGenUiEnabled);
    on<UpdateApiKeyEvent>(_onUpdateApiKey);
    on<UpdateModelNameEvent>(_onUpdateModelName);
    on<UpdateCustomPromptEvent>(_onUpdateCustomPrompt);
    on<ResetPromptToDefaultEvent>(_onResetPromptToDefault);
    on<FetchAvailableModelsEvent>(_onFetchAvailableModels);
  }

  FutureOr<void> _onToggleLlmEnabled(
      ToggleLlmEnabledEvent event, Emitter<LlmSettingsState> emit) {
    sharedPref.llmEnable = event.enabled;
    emit(state.copyWith(llmEnabled: event.enabled));
  }

  FutureOr<void> _onToggleLlmGenUiEnabled(
      ToggleLlmGenUiEnabledEvent event, Emitter<LlmSettingsState> emit) {
    sharedPref.llmGenUiEnable = event.enabled;
    emit(state.copyWith(llmGenUiEnabled: event.enabled));
  }

  FutureOr<void> _onUpdateApiKey(
      UpdateApiKeyEvent event, Emitter<LlmSettingsState> emit) {
    sharedPref.llmApiKey = event.apiKey;
    emit(state.copyWith(apiKey: event.apiKey));
  }

  FutureOr<void> _onUpdateModelName(
      UpdateModelNameEvent event, Emitter<LlmSettingsState> emit) {
    sharedPref.llmModel = event.modelName;
    emit(state.copyWith(modelName: event.modelName));
  }

  FutureOr<void> _onUpdateCustomPrompt(
      UpdateCustomPromptEvent event, Emitter<LlmSettingsState> emit) {
    sharedPref.llmCustomPrompt = event.prompt;
    emit(state.copyWith(
      customPrompt: event.prompt,
      effectivePrompt: sharedPref.effectivePrompt,
    ));
  }

  FutureOr<void> _onResetPromptToDefault(
      ResetPromptToDefaultEvent event, Emitter<LlmSettingsState> emit) {
    sharedPref.llmCustomPrompt = '';
    emit(state.copyWith(
      customPrompt: '',
      effectivePrompt: sharedPref.effectivePrompt,
    ));
  }

  FutureOr<void> _onFetchAvailableModels(
      FetchAvailableModelsEvent event, Emitter<LlmSettingsState> emit) async {
    final apiKey = (event.apiKey ?? sharedPref.llmApiKey).trim();
    if (apiKey.isEmpty) {
      emit(state.copyWith(
        fetchError: 'API Key is required to fetch models.',
      ));
      return;
    }

    emit(state.copyWith(isFetchingModels: true, fetchError: ''));
    try {
      final models = await llmService.fetchAvailableModels(apiKey: apiKey);
      emit(state.copyWith(
        availableModels: models,
        isFetchingModels: false,
        fetchError: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        isFetchingModels: false,
        fetchError: e.toString(),
      ));
    }
  }
}
