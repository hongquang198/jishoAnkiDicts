import 'package:flutter/material.dart';
import 'ai_loading_skeleton.dart';

class AiTutorCard extends StatelessWidget {
  final String? tutorComment;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AiTutorCard({
    super.key,
    this.tutorComment,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const AiLoadingSkeleton(
          message: 'AI Tutor is analyzing word notes...');
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load AI Tutor comments',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    final isEmpty =
        tutorComment == null || tutorComment!.trim().isEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI Tutor Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isEmpty ? 'No AI Tutor insights yet.' : tutorComment!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: isEmpty
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
