import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// Pluggable remote backend contract for user data synchronization.
/// Implementations can be Firebase, Supabase, Appwrite, or custom REST APIs.
abstract class RemoteUserDataDataSource {
  /// Unique identifier of current logged in or anonymous user.
  String? get currentUserId;

  /// Stream of authentication state changes.
  Stream<String?> watchUserId();

  /// Authenticate anonymously or with existing credentials.
  Future<void> signInAnonymously();

  /// Push updated cards to cloud.
  Future<void> pushCards(List<WordCard> cards);

  /// Pull cards updated in cloud since [timestamp].
  Future<List<WordCard>> pullCardsUpdatedSince(int timestamp);

  /// Push word view metrics to cloud.
  Future<void> pushViews(List<WordViewRecord> views);

  /// Pull all word view records from cloud.
  Future<List<WordViewRecord>> pullViews();

  /// Push review logs to cloud.
  Future<void> pushReviewLogs(List<ReviewLog> logs);

  /// Pull review logs from cloud.
  Future<List<ReviewLog>> pullReviewLogs({int? sinceTimestamp});

  /// Delete card in cloud.
  Future<void> deleteCard(String cardId);
}
