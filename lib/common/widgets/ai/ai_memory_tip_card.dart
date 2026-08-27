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
    if (!isLoading && (memoryTip == null || memoryTip!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

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
                Text(
                  'Memory Tip & Mnemonic',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            isLoading
                ? LinearProgressIndicator(
                    color: theme.colorScheme.secondary,
                    backgroundColor:
                        theme.colorScheme.secondary.withValues(alpha: 0.2),
                  )
                : Text(
                    memoryTip!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
