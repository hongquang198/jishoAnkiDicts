import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection.dart';
import '../../../services/llm_service.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/ai_chat_event.dart';
import '../bloc/ai_chat_state.dart';

class AiChatScreenArgs {
  final String word;
  final String? reading;
  final String? definition;
  final String? existingTutorComment;
  final String? existingMemoryTip;
  final String? grammarPoint;

  const AiChatScreenArgs({
    required this.word,
    this.reading,
    this.definition,
    this.existingTutorComment,
    this.existingMemoryTip,
    this.grammarPoint,
  });

  String buildInitialContext() {
    final sb = StringBuffer();
    sb.writeln('Target Word / Grammar: $word');
    if (reading != null) sb.writeln('Reading: $reading');
    if (definition != null) sb.writeln('Definition: $definition');
    if (grammarPoint != null) sb.writeln('Grammar Point: $grammarPoint');
    if (existingTutorComment != null) {
      sb.writeln('Existing AI Tutor Notes: $existingTutorComment');
    }
    if (existingMemoryTip != null) {
      sb.writeln('Existing Memory Tip: $existingMemoryTip');
    }
    return sb.toString();
  }
}

class AiChatScreen extends StatelessWidget {
  final AiChatScreenArgs args;

  const AiChatScreen({super.key, required this.args});

  static Widget provider({required AiChatScreenArgs args}) {
    return BlocProvider(
      create: (context) => AiChatBloc(llmService: getIt<LlmService>())
        ..add(InitializeAiChat(initialContext: args.buildInitialContext())),
      child: AiChatScreen(args: args),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Tutor Chat: ${args.word}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<AiChatBloc, AiChatState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error: ${state.errorMessage}',
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    return _MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          _QuickSuggestionsBar(
            onChipSelected: (chipText) {
              context
                  .read<AiChatBloc>()
                  .add(SelectPromptSuggestion(chipText: chipText));
            },
          ),
          const _ChatInputBar(),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _QuickSuggestionsBar extends StatelessWidget {
  final ValueChanged<String> onChipSelected;

  const _QuickSuggestionsBar({required this.onChipSelected});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Explain nuance & usage',
      'Provide 3 conversational examples',
      'Clarify mnemonic / memory tip',
      'Etymology & loanword origin',
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(suggestion),
              onPressed: () => onChipSelected(suggestion),
            ),
          );
        },
      ),
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar();

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AiChatBloc>().add(SendChatMessage(text: text));
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(context),
              decoration: InputDecoration(
                hintText: 'Ask AI Tutor about this word...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: theme.colorScheme.primary,
            onPressed: () => _send(context),
          ),
        ],
      ),
    );
  }
}
