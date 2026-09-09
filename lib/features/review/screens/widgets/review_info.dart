import 'package:flutter/material.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';

class ReviewInfo extends StatelessWidget {
  final int newCardsCount;
  final int learningCardsCount;
  final int dueCardsCount;

  const ReviewInfo({
    super.key,
    this.newCardsCount = 0,
    this.learningCardsCount = 0,
    this.dueCardsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCountBadge('$newCardsCount', Colors.blue, l.reviewBadgeNew),
          const SizedBox(width: 20),
          _buildCountBadge(
              '$learningCardsCount', Colors.orange, l.reviewBadgeLearn),
          const SizedBox(width: 20),
          _buildCountBadge('$dueCardsCount', Colors.green, l.reviewBadgeDue),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String count, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
