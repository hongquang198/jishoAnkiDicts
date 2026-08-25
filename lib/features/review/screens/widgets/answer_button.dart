import 'package:flutter/material.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/services/srs_engine.dart';

class SrsAnswerButton extends StatelessWidget {
  final WordCard card;
  final SrsRating rating;
  final SrsEngine srsEngine;
  final VoidCallback onTap;

  const SrsAnswerButton({
    super.key,
    required this.card,
    required this.rating,
    required this.srsEngine,
    required this.onTap,
  });

  String get buttonLabel {
    switch (rating) {
      case SrsRating.again:
        return 'Again';
      case SrsRating.hard:
        return 'Hard';
      case SrsRating.good:
        return 'Good';
      case SrsRating.easy:
        return 'Easy';
    }
  }

  Color get buttonColor {
    switch (rating) {
      case SrsRating.again:
        return const Color(0xFFE53935);
      case SrsRating.hard:
        return const Color(0xFFFB8C00);
      case SrsRating.good:
        return const Color(0xFF43A047);
      case SrsRating.easy:
        return const Color(0xFF1E88E5);
    }
  }

  String get intervalEstimate {
    final srs = card.srsData;
    if (srs == null) return '';
    final next = srsEngine.calculateNextState(
      current: srs,
      rating: rating,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );

    final ms = next.intervalMs;
    if (ms < 60 * 1000) return '<1m';
    if (ms < 60 * 60 * 1000) return '${(ms / (60 * 1000)).round()}m';
    if (ms < 24 * 60 * 60 * 1000) return '${(ms / (60 * 60 * 1000)).round()}h';
    if (ms < 30 * 24 * 60 * 60 * 1000) {
      return '${(ms / (24 * 60 * 60 * 1000)).round()}d';
    }
    if (ms < 365 * 24 * 60 * 60 * 1000) {
      return '${(ms / (30 * 24 * 60 * 60 * 1000)).toStringAsFixed(1)}mo';
    }
    return '${(ms / (365 * 24 * 60 * 60 * 1000)).toStringAsFixed(1)}y';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 54,
          color: buttonColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                intervalEstimate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
