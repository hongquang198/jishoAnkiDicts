import 'dart:math';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_data.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';

/// Service implementing the SM-2 Spaced Repetition Scheduling algorithm.
class SrsEngine {
  /// Learning steps in minutes (default: 1 min, 10 min).
  final List<int> learningStepMinutes;

  /// Graduating interval in days (default: 1 day).
  final int graduatingIntervalDays;

  /// Easy interval in days (default: 4 days).
  final int easyIntervalDays;

  /// Multiplier bonus for easy rating (default: 1.3).
  final double easyBonus;

  /// Global interval scaling modifier (default: 1.0).
  final double intervalModifier;

  /// Threshold of lapses before a card is flagged as leech (default: 8).
  final int leechThreshold;

  /// Minimum ease factor allowed.
  static const double minEase = 1.3;

  /// Mature card threshold: 21 days in milliseconds.
  static const int matureThresholdMs = 21 * 24 * 60 * 60 * 1000;

  const SrsEngine({
    this.learningStepMinutes = const [1, 10],
    this.graduatingIntervalDays = 1,
    this.easyIntervalDays = 4,
    this.easyBonus = 1.3,
    this.intervalModifier = 1.0,
    this.leechThreshold = 8,
  });

  List<int> get learningStepMs =>
      learningStepMinutes.map((m) => m * 60 * 1000).toList();

  int get graduatingIntervalMs => graduatingIntervalDays * 24 * 60 * 60 * 1000;
  int get easyIntervalMs => easyIntervalDays * 24 * 60 * 60 * 1000;

  /// Computes the next [SrsData] given a user review [rating] at [nowMs].
  SrsData calculateNextState({
    required SrsData current,
    required SrsRating rating,
    required int nowMs,
  }) {
    final steps = learningStepMs.isNotEmpty ? learningStepMs : [60000, 600000];
    final isFirstReview = current.reviews == 0;
    final firstReviewTimestamp = isFirstReview ? nowMs : current.firstReviewedAt;
    final totalReviews = current.reviews + 1;

    switch (rating) {
      case SrsRating.again:
        final newLapses = current.stage == SrsStage.review
            ? current.lapses + 1
            : current.lapses;
        final isLeech = newLapses >= leechThreshold;
        final newEase = max(minEase, current.easeFactor - 0.20);
        return current.copyWith(
          stage: current.stage == SrsStage.newCard
              ? SrsStage.learning
              : SrsStage.relearning,
          stepIndex: 0,
          intervalMs: steps[0],
          dueAt: nowMs + steps[0],
          easeFactor: newEase,
          reviews: totalReviews,
          lapses: newLapses,
          isLeech: isLeech,
          firstReviewedAt: firstReviewTimestamp,
          lastReviewedAt: nowMs,
        );

      case SrsRating.hard:
        final newEase = max(minEase, current.easeFactor - 0.15);
        if (current.stage == SrsStage.newCard ||
            current.stage == SrsStage.learning ||
            current.stage == SrsStage.relearning) {
          final currentStep = steps[min(current.stepIndex, steps.length - 1)];
          final nextStep = steps[min(current.stepIndex + 1, steps.length - 1)];
          final interval = ((currentStep + nextStep) / 2).round();
          return current.copyWith(
            stage: SrsStage.learning,
            intervalMs: interval,
            dueAt: nowMs + interval,
            easeFactor: newEase,
            reviews: totalReviews,
            firstReviewedAt: firstReviewTimestamp,
            lastReviewedAt: nowMs,
          );
        } else {
          final newInterval =
              max(graduatingIntervalMs, (current.intervalMs * 1.2).round());
          return current.copyWith(
            stage: SrsStage.review,
            intervalMs: newInterval,
            dueAt: nowMs + newInterval,
            easeFactor: newEase,
            reviews: totalReviews,
            firstReviewedAt: firstReviewTimestamp,
            lastReviewedAt: nowMs,
          );
        }

      case SrsRating.good:
        if (current.stage == SrsStage.newCard ||
            current.stage == SrsStage.learning ||
            current.stage == SrsStage.relearning) {
          if (current.stepIndex < steps.length - 1) {
            final nextStepIndex = current.stepIndex + 1;
            final nextInterval = steps[nextStepIndex];
            return current.copyWith(
              stage: SrsStage.learning,
              stepIndex: nextStepIndex,
              intervalMs: nextInterval,
              dueAt: nowMs + nextInterval,
              reviews: totalReviews,
              firstReviewedAt: firstReviewTimestamp,
              lastReviewedAt: nowMs,
            );
          } else {
            // Graduate to review
            return current.copyWith(
              stage: SrsStage.review,
              stepIndex: 0,
              intervalMs: graduatingIntervalMs,
              dueAt: nowMs + graduatingIntervalMs,
              reviews: totalReviews,
              firstReviewedAt: firstReviewTimestamp,
              lastReviewedAt: nowMs,
            );
          }
        } else {
          // Normal review progression
          final calculatedInterval = (current.intervalMs *
                  current.easeFactor *
                  intervalModifier)
              .round();
          final newInterval = max(graduatingIntervalMs, calculatedInterval);
          return current.copyWith(
            stage: SrsStage.review,
            intervalMs: newInterval,
            dueAt: nowMs + newInterval,
            reviews: totalReviews,
            firstReviewedAt: firstReviewTimestamp,
            lastReviewedAt: nowMs,
          );
        }

      case SrsRating.easy:
        final newEase = current.easeFactor + 0.15;
        if (current.stage == SrsStage.newCard ||
            current.stage == SrsStage.learning ||
            current.stage == SrsStage.relearning) {
          // Graduate immediately to easy interval
          return current.copyWith(
            stage: SrsStage.review,
            stepIndex: 0,
            intervalMs: easyIntervalMs,
            dueAt: nowMs + easyIntervalMs,
            easeFactor: newEase,
            reviews: totalReviews,
            firstReviewedAt: firstReviewTimestamp,
            lastReviewedAt: nowMs,
          );
        } else {
          final calculatedInterval = (current.intervalMs *
                  current.easeFactor *
                  easyBonus *
                  intervalModifier)
              .round();
          final newInterval = max(easyIntervalMs, calculatedInterval);
          return current.copyWith(
            stage: SrsStage.review,
            intervalMs: newInterval,
            dueAt: nowMs + newInterval,
            easeFactor: newEase,
            reviews: totalReviews,
            firstReviewedAt: firstReviewTimestamp,
            lastReviewedAt: nowMs,
          );
        }
    }
  }

  /// Builds a deterministic review queue for a session.
  List<WordCard> buildReviewQueue({
    required List<WordCard> allCards,
    required int nowMs,
    int maxNewCards = 30,
    int maxReviews = 999,
  }) {
    final enrolledCards = allCards.where((c) => c.isInReview).toList();

    // 1. Due reviews: cards that have started learning and dueAt <= nowMs
    final dueCards = enrolledCards.where((c) {
      final srs = c.srsData!;
      return srs.stage != SrsStage.newCard && srs.dueAt <= nowMs;
    }).toList();

    // Sort due cards by dueAt ascending (oldest due first)
    dueCards.sort((a, b) => a.srsData!.dueAt.compareTo(b.srsData!.dueAt));

    // Limit review cards
    final limitedDueCards = dueCards.take(maxReviews).toList();

    // 2. New cards: cards that haven't been reviewed yet
    final newCards = enrolledCards.where((c) {
      return c.srsData!.stage == SrsStage.newCard;
    }).take(maxNewCards).toList();

    // Queue order: due reviews first, then new cards
    return [...limitedDueCards, ...newCards];
  }

  /// Computes comprehensive study statistics.
  UserStudyStats computeStats({
    required List<WordCard> cards,
    required List<ReviewLog> reviewLogs,
    required DateTime now,
  }) {
    final endOfTodayMs =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
            .millisecondsSinceEpoch;

    int newCount = 0;
    int youngCount = 0;
    int matureCount = 0;
    int difficultCount = 0;
    int dueToday = 0;

    for (final card in cards) {
      if (!card.isInReview) continue;
      final srs = card.srsData!;

      if (srs.stage == SrsStage.newCard) {
        newCount++;
        dueToday++;
      } else {
        if (srs.isLeech || srs.lapses > 5) {
          difficultCount++;
        }

        if (srs.intervalMs > matureThresholdMs) {
          matureCount++;
        } else {
          youngCount++;
        }

        if (srs.dueAt <= endOfTodayMs) {
          dueToday++;
        }
      }
    }

    // 7-day forecast
    final List<DayForecast> forecast = [];
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      final dayStartMs = DateTime(targetDate.year, targetDate.month, targetDate.day)
          .millisecondsSinceEpoch;
      final dayEndMs =
          DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59, 999)
              .millisecondsSinceEpoch;

      int dayNew = i == 0 ? newCount : 0;
      int dayYoung = 0;
      int dayMature = 0;
      int dayDifficult = 0;

      for (final card in cards) {
        if (!card.isInReview) continue;
        final srs = card.srsData!;
        if (srs.stage == SrsStage.newCard) continue;

        final isDueOnDay = i == 0
            ? srs.dueAt <= dayEndMs
            : (srs.dueAt >= dayStartMs && srs.dueAt <= dayEndMs);

        if (isDueOnDay) {
          if (srs.isLeech || srs.lapses > 5) {
            dayDifficult++;
          }
          if (srs.intervalMs > matureThresholdMs) {
            dayMature++;
          } else {
            dayYoung++;
          }
        }
      }

      final label = weekdayLabels[targetDate.weekday - 1];
      forecast.add(DayForecast(
        date: targetDate,
        dayLabel: label,
        newCards: dayNew,
        youngCards: dayYoung,
        matureCards: dayMature,
        difficultCards: dayDifficult,
      ));
    }

    // Retention Rate & Heatmap from review logs
    int totalLogs = reviewLogs.length;
    int successfulLogs = reviewLogs
        .where((l) => l.rating == SrsRating.good || l.rating == SrsRating.easy)
        .length;
    final retentionRate = totalLogs > 0 ? (successfulLogs / totalLogs) : 0.0;

    final Map<String, int> heatmap = {};
    for (final log in reviewLogs) {
      final dt = DateTime.fromMillisecondsSinceEpoch(log.reviewedAt);
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      heatmap[key] = (heatmap[key] ?? 0) + 1;
    }

    return UserStudyStats(
      dueToday: dueToday,
      newCount: newCount,
      youngCount: youngCount,
      matureCount: matureCount,
      difficultCount: difficultCount,
      retentionRate: retentionRate,
      sevenDaysForecast: forecast,
      activityHeatmap: heatmap,
    );
  }
}
