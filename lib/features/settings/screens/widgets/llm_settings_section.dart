import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../injection.dart';
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
    final isVn = getIt<SharedPref>().isAppInVietnamese;

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
        if (!state.isFetchingModels && state.availableModels.isNotEmpty && state.fetchError.isEmpty) {
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
                isVn ? 'Cấu hình AI / LLM (Gemini)' : 'AI / LLM Settings (Gemini)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Enable/Disable toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(isVn ? 'Bật giải thích AI' : 'Enable AI Explanation'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Switch(
                    value: state.llmEnabled,
                    onChanged: (val) {
                      context.read<LlmSettingsBloc>().add(ToggleLlmEnabledEvent(val));
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
                  const Text(
                    'Gemini API Key:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: isVn ? 'Nhập Gemini API Key' : 'Enter Gemini API Key',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                      ),
                    ),
                    onChanged: (val) {
                      context.read<LlmSettingsBloc>().add(UpdateApiKeyEvent(val));
                    },
                  ),
                  const SizedBox(height: 15),

                  // Model Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          isVn ? 'Tên Model (Gemini):' : 'LLM Model Name:',
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
                                        isVn
                                            ? 'Vui lòng nhập API Key trước.'
                                            : 'Please enter an API Key first.',
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
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync, size: 16),
                        label: Text(isVn ? 'Tải từ API' : 'Fetch from API'),
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
                            context.read<LlmSettingsBloc>().add(UpdateModelNameEvent(val));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                        tooltip: isVn ? 'Chọn Model' : 'Select Model',
                        enabled: state.availableModels.isNotEmpty,
                        onSelected: (model) {
                          _modelController.text = model;
                          context.read<LlmSettingsBloc>().add(UpdateModelNameEvent(model));
                        },
                        itemBuilder: (context) {
                          if (state.availableModels.isEmpty) {
                            return [
                              PopupMenuItem(
                                enabled: false,
                                child: Text(
                                  isVn
                                      ? 'Nhấn "Tải từ API" để lấy danh sách'
                                      : 'Press "Fetch from API" to load list',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ];
                          }
                          return state.availableModels
                              .map((m) => PopupMenuItem(value: m, child: Text(m)))
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
                          isVn ? 'Mẫu Prompt (Custom):' : 'Custom Prompt Template:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<LlmSettingsBloc>().add(const ResetPromptToDefaultEvent());
                        },
                        child: Text(isVn ? 'Đặt lại mặc định' : 'Reset to Default'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _promptController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: isVn
                          ? 'Sử dụng %search_words% để thay thế từ tra cứu'
                          : 'Use %search_words% as query placeholder',
                    ),
                    onChanged: (val) {
                      context.read<LlmSettingsBloc>().add(UpdateCustomPromptEvent(val));
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
