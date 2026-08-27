import 'package:flutter/material.dart';

class AiGrammarBreakdownCard extends StatelessWidget {
  final String? grammarAnalysis;
  final bool isLoading;

  const AiGrammarBreakdownCard({
    super.key,
    this.grammarAnalysis,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading &&
        (grammarAnalysis == null || grammarAnalysis!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

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
                Text(
                  'Grammar & Structure Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            isLoading
                ? LinearProgressIndicator(
                    color: theme.colorScheme.tertiary,
                    backgroundColor:
                        theme.colorScheme.tertiary.withValues(alpha: 0.2),
                  )
                : Text(
                    grammarAnalysis!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
