import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_data.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/services/srs_engine.dart';

void main() {
  group('SrsEngine SM-2 Algorithm Tests', () {
    const engine = SrsEngine(
      learningStepMinutes: [1, 10],
      graduatingIntervalDays: 1,
      easyIntervalDays: 4,
      easyBonus: 1.3,
      intervalModifier: 1.0,
      leechThreshold: 8,
    );

    const int now = 1000000;

    test('New card with Rating.Again transitions to learning step 0', () {
      final initial = SrsData.initial();
      final next = engine.calculateNextState(
        current: initial,
        rating: SrsRating.again,
        nowMs: now,
      );

      expect(next.stage, equals(SrsStage.learning));
      expect(next.stepIndex, equals(0));
      expect(next.intervalMs, equals(1 * 60 * 1000));
      expect(next.dueAt, equals(now + 1 * 60 * 1000));
      expect(next.reviews, equals(1));
      expect(next.firstReviewedAt, equals(now));
      expect(next.lastReviewedAt, equals(now));
    });

    test('New card with Rating.Good advances learning step to step 1', () {
      final initial = SrsData.initial();
      final next = engine.calculateNextState(
        current: initial,
        rating: SrsRating.good,
        nowMs: now,
      );

      expect(next.stage, equals(SrsStage.learning));
      expect(next.stepIndex, equals(1));
      expect(next.intervalMs, equals(10 * 60 * 1000));
      expect(next.dueAt, equals(now + 10 * 60 * 1000));
      expect(next.reviews, equals(1));
    });

    test('Learning card at final step with Rating.Good graduates to review', () {
      const learningCard = SrsData(
        stage: SrsStage.learning,
        stepIndex: 1,
        intervalMs: 10 * 60 * 1000,
        reviews: 1,
      );

      final next = engine.calculateNextState(
        current: learningCard,
        rating: SrsRating.good,
        nowMs: now,
      );

      expect(next.stage, equals(SrsStage.review));
      expect(next.stepIndex, equals(0));
      expect(next.intervalMs, equals(1 * 24 * 60 * 60 * 1000)); // 1 day
      expect(next.dueAt, equals(now + 1 * 24 * 60 * 60 * 1000));
      expect(next.reviews, equals(2));
    });

    test('New card with Rating.Easy graduates immediately to easy interval (4 days)', () {
      final initial = SrsData.initial();
      final next = engine.calculateNextState(
        current: initial,
        rating: SrsRating.easy,
        nowMs: now,
      );

      expect(next.stage, equals(SrsStage.review));
      expect(next.intervalMs, equals(4 * 24 * 60 * 60 * 1000)); // 4 days
      expect(next.dueAt, equals(now + 4 * 24 * 60 * 60 * 1000));
      expect(next.easeFactor, closeTo(2.65, 0.001)); // 2.5 + 0.15
    });

    test('Review card with Rating.Good increases interval by easeFactor', () {
      const reviewCard = SrsData(
        stage: SrsStage.review,
        intervalMs: 1 * 24 * 60 * 60 * 1000, // 1 day
        easeFactor: 2.5,
        reviews: 2,
      );

      final next = engine.calculateNextState(
        current: reviewCard,
        rating: SrsRating.good,
        nowMs: now,
      );

      final expectedInterval = (1 * 24 * 60 * 60 * 1000 * 2.5).round();
      expect(next.stage, equals(SrsStage.review));
      expect(next.intervalMs, equals(expectedInterval));
      expect(next.dueAt, equals(now + expectedInterval));
      expect(next.easeFactor, equals(2.5));
    });

    test('Review card with Rating.Again lapses and resets to relearning', () {
      const reviewCard = SrsData(
        stage: SrsStage.review,
        intervalMs: 10 * 24 * 60 * 60 * 1000,
        easeFactor: 2.5,
        reviews: 5,
        lapses: 0,
      );

      final next = engine.calculateNextState(
        current: reviewCard,
        rating: SrsRating.again,
        nowMs: now,
      );

      expect(next.stage, equals(SrsStage.relearning));
      expect(next.stepIndex, equals(0));
      expect(next.intervalMs, equals(1 * 60 * 1000));
      expect(next.lapses, equals(1));
      expect(next.easeFactor, closeTo(2.30, 0.001)); // 2.5 - 0.20
      expect(next.isLeech, isFalse);
    });

    test('Card reaching leech threshold is flagged as leech', () {
      const reviewCard = SrsData(
        stage: SrsStage.review,
        intervalMs: 5 * 24 * 60 * 60 * 1000,
        easeFactor: 1.5,
        reviews: 10,
        lapses: 7, // 7 + 1 = 8 => threshold
      );

      final next = engine.calculateNextState(
        current: reviewCard,
        rating: SrsRating.again,
        nowMs: now,
      );

      expect(next.lapses, equals(8));
      expect(next.isLeech, isTrue);
    });
  });

  group('Review Queue Construction Tests', () {
    const engine = SrsEngine();
    const now = 5000000;

    test('Builds deterministic queue prioritizing overdue cards before new cards', () {
      final cards = [
        WordCard(
          id: 'card1',
          word: '猫',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData(
            stage: SrsStage.review,
            dueAt: now - 10000, // Overdue by 10s
            intervalMs: 86400000,
            reviews: 3,
          ),
        ),
        WordCard(
          id: 'card2',
          word: '犬',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData(
            stage: SrsStage.review,
            dueAt: now - 50000, // Overdue by 50s (older)
            intervalMs: 86400000,
            reviews: 3,
          ),
        ),
        WordCard(
          id: 'card3',
          word: '鳥',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData.initial(), // New card
        ),
        WordCard(
          id: 'card4',
          word: '魚',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: null, // Not in review
        ),
        WordCard(
          id: 'card5',
          word: '山',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData(
            stage: SrsStage.review,
            dueAt: now + 50000, // Not due yet
            intervalMs: 86400000,
            reviews: 3,
          ),
        ),
      ];

      final queue = engine.buildReviewQueue(allCards: cards, nowMs: now);

      expect(queue.length, equals(3));
      expect(queue[0].word, equals('犬')); // Oldest due first
      expect(queue[1].word, equals('猫')); // Second due
      expect(queue[2].word, equals('鳥')); // New card
    });
  });

  group('User Study Statistics Computation Tests', () {
    const engine = SrsEngine();
    final now = DateTime(2026, 8, 25, 12, 0);

    test('Computes correct daily counts and retention rate', () {
      final cards = [
        WordCard(
          id: 'new1',
          word: '新',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData.initial(),
        ),
        WordCard(
          id: 'young1',
          word: '若',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData(
            stage: SrsStage.review,
            dueAt: now.millisecondsSinceEpoch - 1000,
            intervalMs: 2 * 24 * 60 * 60 * 1000, // 2 days -> young
            reviews: 2,
          ),
        ),
        WordCard(
          id: 'mature1',
          word: '熟',
          addedAt: 1000,
          updatedAt: 1000,
          srsData: SrsData(
            stage: SrsStage.review,
            dueAt: now.millisecondsSinceEpoch - 1000,
            intervalMs: 30 * 24 * 60 * 60 * 1000, // 30 days -> mature
            reviews: 10,
          ),
        ),
      ];

      final logs = [
        ReviewLog(
          id: 'log1',
          cardId: 'young1',
          rating: SrsRating.good,
          reviewedAt: now.millisecondsSinceEpoch,
        ),
        ReviewLog(
          id: 'log2',
          cardId: 'mature1',
          rating: SrsRating.again,
          reviewedAt: now.millisecondsSinceEpoch,
        ),
      ];

      final stats = engine.computeStats(cards: cards, reviewLogs: logs, now: now);

      expect(stats.newCount, equals(1));
      expect(stats.youngCount, equals(1));
      expect(stats.matureCount, equals(1));
      expect(stats.dueToday, equals(3));
      expect(stats.retentionRate, equals(0.5)); // 1 good out of 2 logs
      expect(stats.sevenDaysForecast.length, equals(7));
    });
  });
}
