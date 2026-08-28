import 'package:flutter/material.dart';

class AiGrammarBreakdownCard extends StatelessWidget {
  final String? grammarAnalysis;
  final bool isLoading;
  final VoidCallback? onAskAiTutor;

  const AiGrammarBreakdownCard({
    super.key,
    this.grammarAnalysis,
    this.isLoading = false,
    this.onAskAiTutor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = grammarAnalysis == null || grammarAnalysis!.trim().isEmpty;

    final Widget body;
    if (isLoading) {
      body = LinearProgressIndicator(
        color: theme.colorScheme.tertiary,
        backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.2),
      );
    } else if (isEmpty) {
      body = Text(
        'No grammar breakdown available yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    } else {
      body = Text(
        grammarAnalysis!,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rule_folder_outlined,
                  color: theme.colorScheme.tertiary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Grammar & Structure Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
                if (onAskAiTutor != null)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    tooltip: 'Ask AI Tutor',
                    onPressed: onAskAiTutor,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }
}
