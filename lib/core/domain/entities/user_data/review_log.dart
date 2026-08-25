import 'package:equatable/equatable.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';

/// Records the history of a single review attempt for statistics and retention calculation.
class ReviewLog extends Equatable {
  final String id;
  final String cardId;
  final SrsRating rating;
  final int reviewDurationMs;
  final int reviewedAt;
  final int previousIntervalMs;
  final int newIntervalMs;
  final double previousEase;
  final double newEase;
  final bool isSynced;

  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    this.reviewDurationMs = 0,
    required this.reviewedAt,
    this.previousIntervalMs = 0,
    this.newIntervalMs = 0,
    this.previousEase = 2.5,
    this.newEase = 2.5,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'rating': rating.name,
      'duration_ms': reviewDurationMs,
      'reviewed_at': reviewedAt,
      'prev_interval_ms': previousIntervalMs,
      'new_interval_ms': newIntervalMs,
      'prev_ease': previousEase,
      'new_ease': newEase,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory ReviewLog.fromMap(Map<String, dynamic> map) {
    return ReviewLog(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      rating: SrsRating.values.firstWhere(
        (e) => e.name == map['rating'],
        orElse: () => SrsRating.good,
      ),
      reviewDurationMs: (map['duration_ms'] as num?)?.toInt() ?? 0,
      reviewedAt: (map['reviewed_at'] as num?)?.toInt() ?? 0,
      previousIntervalMs: (map['prev_interval_ms'] as num?)?.toInt() ?? 0,
      newIntervalMs: (map['new_interval_ms'] as num?)?.toInt() ?? 0,
      previousEase: (map['prev_ease'] as num?)?.toDouble() ?? 2.5,
      newEase: (map['new_ease'] as num?)?.toDouble() ?? 2.5,
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cardId,
        rating,
        reviewDurationMs,
        reviewedAt,
        previousIntervalMs,
        newIntervalMs,
        previousEase,
        newEase,
        isSynced,
      ];
}
