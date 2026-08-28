import 'package:flutter/material.dart';

class AiMemoryTipCard extends StatelessWidget {
  final String? memoryTip;
  final bool isLoading;

  const AiMemoryTipCard({
    super.key,
    this.memoryTip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = memoryTip == null || memoryTip!.trim().isEmpty;

    final Widget body;
    if (isLoading) {
      body = LinearProgressIndicator(
        color: theme.colorScheme.secondary,
        backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
      );
    } else if (isEmpty) {
      body = Text(
        'No memory tip available yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    } else {
      body = Text(
        memoryTip!,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.secondary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Memory Tip & Mnemonic',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
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
