import 'package:equatable/equatable.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';

/// Spaced Repetition metadata for a card.
class SrsData extends Equatable {
  /// Current lifecycle stage of the card.
  final SrsStage stage;

  /// Epoch timestamp (milliseconds) when the card is due for review.
  final int dueAt;

  /// Current interval in milliseconds.
  final int intervalMs;

  /// Ease factor (multiplier for interval growth), typically starts at 2.5 (min 1.3).
  final double easeFactor;

  /// Index of the current learning step (e.g. 0 for 1m, 1 for 10m).
  final int stepIndex;

  /// Total number of review attempts.
  final int reviews;

  /// Number of times the card lapsed (failed after graduating).
  final int lapses;

  /// Epoch timestamp of the first review, if any.
  final int? firstReviewedAt;

  /// Epoch timestamp of the most recent review, if any.
  final int? lastReviewedAt;

  /// Flag indicating if the card has exceeded the leech threshold.
  final bool isLeech;

  const SrsData({
    this.stage = SrsStage.newCard,
    this.dueAt = 0,
    this.intervalMs = 0,
    this.easeFactor = 2.5,
    this.stepIndex = 0,
    this.reviews = 0,
    this.lapses = 0,
    this.firstReviewedAt,
    this.lastReviewedAt,
    this.isLeech = false,
  });

  /// Factory for a brand-new card.
  factory SrsData.initial({double startingEase = 2.5}) {
    return SrsData(
      stage: SrsStage.newCard,
      dueAt: 0,
      intervalMs: 0,
      easeFactor: startingEase,
      stepIndex: 0,
      reviews: 0,
      lapses: 0,
      firstReviewedAt: null,
      lastReviewedAt: null,
      isLeech: false,
    );
  }

  SrsData copyWith({
    SrsStage? stage,
    int? dueAt,
    int? intervalMs,
    double? easeFactor,
    int? stepIndex,
    int? reviews,
    int? lapses,
    int? firstReviewedAt,
    int? lastReviewedAt,
    bool? isLeech,
  }) {
    return SrsData(
      stage: stage ?? this.stage,
      dueAt: dueAt ?? this.dueAt,
      intervalMs: intervalMs ?? this.intervalMs,
      easeFactor: easeFactor ?? this.easeFactor,
      stepIndex: stepIndex ?? this.stepIndex,
      reviews: reviews ?? this.reviews,
      lapses: lapses ?? this.lapses,
      firstReviewedAt: firstReviewedAt ?? this.firstReviewedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isLeech: isLeech ?? this.isLeech,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stage': stage.name,
      'due_at': dueAt,
      'interval_ms': intervalMs,
      'ease_factor': easeFactor,
      'step_index': stepIndex,
      'reviews': reviews,
      'lapses': lapses,
      'first_reviewed_at': firstReviewedAt,
      'last_reviewed_at': lastReviewedAt,
      'is_leech': isLeech ? 1 : 0,
    };
  }

  factory SrsData.fromMap(Map<String, dynamic> map) {
    return SrsData(
      stage: SrsStage.values.firstWhere(
        (e) => e.name == map['stage'],
        orElse: () => SrsStage.newCard,
      ),
      dueAt: map['due_at'] as int? ?? 0,
      intervalMs: map['interval_ms'] as int? ?? 0,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
      stepIndex: map['step_index'] as int? ?? 0,
      reviews: map['reviews'] as int? ?? 0,
      lapses: map['lapses'] as int? ?? 0,
      firstReviewedAt: map['first_reviewed_at'] as int?,
      lastReviewedAt: map['last_reviewed_at'] as int?,
      isLeech: map['is_leech'] == 1 || map['is_leech'] == true,
    );
  }

  @override
  List<Object?> get props => [
        stage,
        dueAt,
        intervalMs,
        easeFactor,
        stepIndex,
        reviews,
        lapses,
        firstReviewedAt,
        lastReviewedAt,
        isLeech,
      ];
}
