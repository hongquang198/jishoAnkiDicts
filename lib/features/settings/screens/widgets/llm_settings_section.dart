import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../bloc/llm_settings_bloc.dart';

class LlmSettingsSection extends StatefulWidget {
  const LlmSettingsSection({super.key});

  @override
  State<LlmSettingsSection> createState() => _LlmSettingsSectionState();
}

class _LlmSettingsSectionState extends State<LlmSettingsSection> {
  late TextEditingController _apiKeyController;
  late TextEditingController _promptController;
  late TextEditingController _modelController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LlmSettingsBloc>();
    _apiKeyController = TextEditingController(text: bloc.state.apiKey);
    _promptController = TextEditingController(text: bloc.state.effectivePrompt);
    _modelController = TextEditingController(text: bloc.state.modelName);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _promptController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return BlocConsumer<LlmSettingsBloc, LlmSettingsState>(
      listener: (context, state) {
        // Sync text controllers when state changes externally (e.g. reset prompt)
        if (_promptController.text != state.effectivePrompt) {
          _promptController.text = state.effectivePrompt;
        }
        if (_modelController.text != state.modelName) {
          _modelController.text = state.modelName;
        }

        // Show snackbar on fetch error
        if (state.fetchError.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.fetchError),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Show success snackbar when models are fetched
        if (!state.isFetchingModels &&
            state.availableModels.isNotEmpty &&
            state.fetchError.isEmpty) {
          // Only show on transition (we check that fetching just completed)
        }
      },
      listenWhen: (prev, curr) {
        // Listen when fetch completes or errors
        return prev.isFetchingModels != curr.isFetchingModels ||
            prev.effectivePrompt != curr.effectivePrompt ||
            prev.modelName != curr.modelName;
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(thickness: 1.5, height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                l.aiLlmSettingsTitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Enable/Disable toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(l.enableAiExplanation),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Switch(
                    value: state.llmEnabled,
                    onChanged: (val) {
                      context
                          .read<LlmSettingsBloc>()
                          .add(ToggleLlmEnabledEvent(val));
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(l.useGenuiInterface),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Switch(
                    value: state.llmGenUiEnabled,
                    onChanged: (val) {
                      context
                          .read<LlmSettingsBloc>()
                          .add(ToggleLlmGenUiEnabledEvent(val));
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Key
                  Text(
                    l.geminiApiKeyLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l.enterGeminiApiKeyHint,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                      ),
                    ),
                    onChanged: (val) {
                      context
                          .read<LlmSettingsBloc>()
                          .add(UpdateApiKeyEvent(val));
                    },
                  ),
                  const SizedBox(height: 15),

                  // Model Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l.llmModelNameLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: state.isFetchingModels
                            ? null
                            : () {
                                final apiKey = _apiKeyController.text.trim();
                                if (apiKey.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l.enterApiKeyFirst,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                context.read<LlmSettingsBloc>().add(
                                      FetchAvailableModelsEvent(apiKey: apiKey),
                                    );
                              },
                        icon: state.isFetchingModels
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync, size: 16),
                        label: Text(l.fetchFromApi),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'gemini-2.0-flash',
                          ),
                          onChanged: (val) {
                            context
                                .read<LlmSettingsBloc>()
                                .add(UpdateModelNameEvent(val));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                        tooltip: l.selectModel,
                        enabled: state.availableModels.isNotEmpty,
                        onSelected: (model) {
                          _modelController.text = model;
                          context
                              .read<LlmSettingsBloc>()
                              .add(UpdateModelNameEvent(model));
                        },
                        itemBuilder: (context) {
                          if (state.availableModels.isEmpty) {
                            return [
                              PopupMenuItem(
                                enabled: false,
                                child: Text(
                                  l.pressFetchToLoadList,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ];
                          }
                          return state.availableModels
                              .map((m) =>
                                  PopupMenuItem(value: m, child: Text(m)))
                              .toList();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Custom Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l.customPromptTemplateLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<LlmSettingsBloc>()
                              .add(const ResetPromptToDefaultEvent());
                        },
                        child: Text(l.resetToDefault),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _promptController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l.customPromptHint,
                    ),
                    onChanged: (val) {
                      context
                          .read<LlmSettingsBloc>()
                          .add(UpdateCustomPromptEvent(val));
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
