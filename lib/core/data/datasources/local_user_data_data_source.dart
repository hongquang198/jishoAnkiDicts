import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// Contract for local offline cache database (e.g. SQLite / Isar).
abstract class LocalUserDataDataSource {
  Future<void> init();

  // Cards (Favorites & SRS Reviews)
  Future<void> upsertCard(WordCard card);
  Future<void> upsertBatchCards(List<WordCard> cards);
  Future<WordCard?> getCard(String id);
  Future<List<WordCard>> getAllCards();
  Future<List<WordCard>> getFavorites();
  Future<List<WordCard>> getReviewCards();
  Future<void> deleteCard(String id);

  // Word Views
  Future<void> recordView(String word, {int? timestamp});
  Future<WordViewRecord?> getViewRecord(String word);
  Future<List<WordViewRecord>> getAllViewRecords();

  // History
  Future<void> addHistory(WordCard card);
  Future<List<WordCard>> getHistory({int limit = 100});
  Future<void> deleteHistory(String id);
  Future<void> clearHistory();

  // Review Logs
  Future<void> insertReviewLog(ReviewLog log);
  Future<void> deleteReviewLog(String logId);
  Future<List<ReviewLog>> getReviewLogs({int? sinceTimestamp});

  // Sync helpers
  Future<List<WordCard>> getUnsyncedCards();
  Future<List<WordViewRecord>> getUnsyncedViews();
  Future<List<ReviewLog>> getUnsyncedReviewLogs();
  Future<void> markCardsSynced(List<String> cardIds);
  Future<void> markViewsSynced(List<String> words);
  Future<void> markReviewLogsSynced(List<String> logIds);
}
