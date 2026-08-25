import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// Contract for User Data persistence, SRS reviews, favorites, history, and stats.
abstract class UserDataRepository {
  /// Stream of all user cards (favorites & review cards).
  Stream<List<WordCard>> watchAllCards();

  /// Stream of favorite cards only.
  Stream<List<WordCard>> watchFavorites();

  /// Stream of cards enrolled in the review deck.
  Stream<List<WordCard>> watchReviewCards();

  /// Stream of word view records.
  Stream<Map<String, WordViewRecord>> watchWordViews();

  /// Stream of search/lookup history entries.
  Stream<List<WordCard>> watchHistory();

  /// Fetches a specific card by word or ID.
  Future<WordCard?> getCard(String id);

  /// Saves or updates a word card.
  Future<void> saveCard(WordCard card);

  /// Removes a card completely or unsets favorite/review status.
  Future<void> deleteCard(String id);

  /// Toggles favorite status for a word card.
  Future<void> toggleFavorite({
    required WordCard card,
  });

  /// Adds or updates SRS enrollment for a card.
  Future<void> toggleReviewEnrollment({
    required WordCard card,
  });

  /// Submits a review rating for a card, recalculating SRS schedule and appending a log.
  Future<WordCard> submitReview({
    required WordCard card,
    required SrsRating rating,
    int durationMs = 0,
  });

  /// Reverts a review attempt (undo).
  Future<void> revertReview({
    required WordCard previousCardState,
    required String logIdToDelete,
  });

  /// Records a view for a word, incrementing view count reactively.
  Future<void> recordWordView(String word);

  /// Gets the current view count for a word.
  Future<int> getWordViewCount(String word);

  /// Appends a word lookup to history.
  Future<void> addHistory(WordCard card);

  /// Clears all history entries.
  Future<void> clearHistory();

  /// Removes a specific history entry.
  Future<void> removeHistory(String id);

  /// Calculates aggregated learning statistics.
  Future<UserStudyStats> getStudyStats();

  /// Manually triggers bidirectional remote synchronization.
  Future<void> syncWithRemote();
}
