import 'dart:developer';
import 'package:jisho_anki/core/data/datasources/local_user_data_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_data.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/models/offline_word_record.dart';
import 'package:jisho_anki/services/db_manager.dart';

/// Utility to migrate legacy SQLite records from `offlineDatabase.db` into `user_data.db`.
class UserDataMigrator {
  final LocalUserDataDataSource localDataSource;
  final DbManager legacyDbManager;

  UserDataMigrator({
    required this.localDataSource,
    required this.legacyDbManager,
  });

  /// Executes one-time migration if needed.
  Future<void> migrateLegacyData() async {
    try {
      final existingCards = await localDataSource.getAllCards();
      final existingHistory = await localDataSource.getHistory(limit: 1);

      // If user data already exists in the new DB, skip migration
      if (existingCards.isNotEmpty || existingHistory.isNotEmpty) {
        log('UserDataMigrator: New user database already populated. Skipping migration.');
        return;
      }

      log('UserDataMigrator: Starting migration from legacy offlineDatabase.db...');

      // 1. Migrate Favorites
      List<OfflineWordRecord> legacyFavorites = [];
      try {
        legacyFavorites = await legacyDbManager.retrieve(tableName: 'favorite');
      } catch (e) {
        log('UserDataMigrator: No legacy favorites found ($e)');
      }

      for (final legacy in legacyFavorites) {
        final card = _convertLegacyFavorite(legacy);
        await localDataSource.upsertCard(card);
      }

      // 2. Migrate Review cards
      List<OfflineWordRecord> legacyReviews = [];
      try {
        legacyReviews = await legacyDbManager.retrieve(tableName: 'review');
      } catch (e) {
        log('UserDataMigrator: No legacy reviews found ($e)');
      }

      for (final legacy in legacyReviews) {
        final card = _convertLegacyReview(legacy);
        final existing = await localDataSource.getCard(card.id);
        if (existing != null) {
          // Merge favorite + review
          await localDataSource.upsertCard(
            existing.copyWith(srsData: card.srsData),
          );
        } else {
          await localDataSource.upsertCard(card);
        }
      }

      // 3. Migrate History & extract real Word Views
      List<OfflineWordRecord> legacyHistory = [];
      try {
        legacyHistory = await legacyDbManager.retrieve(tableName: 'history');
      } catch (e) {
        log('UserDataMigrator: No legacy history found ($e)');
      }

      for (final legacy in legacyHistory) {
        final card = _convertLegacyHistory(legacy);
        await localDataSource.addHistory(card);

        // Extract view count that was previously stored in `reviews`
        final viewCount = legacy.reviews > 0 ? legacy.reviews : 1;
        final timestamp = legacy.added > 0 ? legacy.added : DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < viewCount; i++) {
          await localDataSource.recordView(card.japaneseWord, timestamp: timestamp);
        }
      }

      log('UserDataMigrator: Successfully migrated ${legacyFavorites.length} favorites, ${legacyReviews.length} reviews, and ${legacyHistory.length} history items.');
    } catch (e, stack) {
      log('UserDataMigrator: Error during migration: $e\n$stack');
    }
  }

  WordCard _convertLegacyFavorite(OfflineWordRecord legacy) {
    final word = legacy.japaneseWord;
    final now = legacy.added > 0 ? legacy.added : DateTime.now().millisecondsSinceEpoch;
    return WordCard(
      id: word,
      word: legacy.word,
      slug: legacy.slug,
      reading: legacy.reading,
      isCommon: legacy.isCommon,
      tags: legacy.tags,
      jlpt: legacy.jlpt,
      senses: legacy.senses,
      vietnameseDefinition: legacy.vietnameseDefinition,
      isFavorite: true,
      srsData: null,
      addedAt: now,
      updatedAt: now,
      isSynced: false,
    );
  }

  WordCard _convertLegacyReview(OfflineWordRecord legacy) {
    final word = legacy.japaneseWord;
    final now = legacy.added > 0 ? legacy.added : DateTime.now().millisecondsSinceEpoch;
    final stage = legacy.reviews == 0
        ? SrsStage.newCard
        : (legacy.interval > 21 * 24 * 60 * 60 * 1000
            ? SrsStage.review
            : SrsStage.learning);

    return WordCard(
      id: word,
      word: legacy.word,
      slug: legacy.slug,
      reading: legacy.reading,
      isCommon: legacy.isCommon,
      tags: legacy.tags,
      jlpt: legacy.jlpt,
      senses: legacy.senses,
      vietnameseDefinition: legacy.vietnameseDefinition,
      isFavorite: false,
      srsData: SrsData(
        stage: stage,
        dueAt: legacy.due > 0 ? legacy.due : now,
        intervalMs: legacy.interval > 0 ? legacy.interval : 60000,
        easeFactor: legacy.ease > 0 ? legacy.ease : 2.5,
        stepIndex: 0,
        reviews: legacy.reviews,
        lapses: legacy.lapses,
        firstReviewedAt: legacy.firstReview,
        lastReviewedAt: legacy.lastReview,
        isLeech: legacy.lapses >= 8,
      ),
      addedAt: now,
      updatedAt: now,
      isSynced: false,
    );
  }

  WordCard _convertLegacyHistory(OfflineWordRecord legacy) {
    final word = legacy.japaneseWord;
    final now = legacy.added > 0 ? legacy.added : DateTime.now().millisecondsSinceEpoch;
    return WordCard(
      id: word,
      word: legacy.word,
      slug: legacy.slug,
      reading: legacy.reading,
      isCommon: legacy.isCommon,
      tags: legacy.tags,
      jlpt: legacy.jlpt,
      senses: legacy.senses,
      vietnameseDefinition: legacy.vietnameseDefinition,
      isFavorite: false,
      srsData: null,
      addedAt: now,
      updatedAt: now,
      isSynced: false,
    );
  }
}
