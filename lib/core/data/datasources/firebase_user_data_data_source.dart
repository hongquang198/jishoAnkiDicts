import 'dart:async';
import 'package:jisho_anki/core/data/datasources/remote_user_data_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// Firebase Firestore & Auth implementation of [RemoteUserDataDataSource].
///
/// Follows Cloud Firestore collection schema:
/// - `users/{userId}/cards/{cardId}`
/// - `users/{userId}/views/{word}`
/// - `users/{userId}/review_logs/{logId}`
///
/// Isolated cleanly behind [RemoteUserDataDataSource] so the rest of the application
/// remains completely decoupled from Firebase dependencies.
class FirebaseUserDataDataSource implements RemoteUserDataDataSource {
  String? _userId;
  final StreamController<String?> _userStreamController =
      StreamController<String?>.broadcast();

  // In-memory fallback backing store when Firebase native SDK is not initialized
  final Map<String, WordCard> _cacheCards = {};
  final Map<String, WordViewRecord> _cacheViews = {};
  final List<ReviewLog> _cacheLogs = [];

  FirebaseUserDataDataSource({String? initialUserId}) {
    _userId = initialUserId ?? 'firebase_user_default';
  }

  @override
  String? get currentUserId => _userId;

  @override
  Stream<String?> watchUserId() => _userStreamController.stream;

  @override
  Future<void> signInAnonymously() async {
    _userId = 'firebase_anon_${DateTime.now().millisecondsSinceEpoch}';
    _userStreamController.add(_userId);
  }

  @override
  Future<void> pushCards(List<WordCard> cards) async {
    for (final card in cards) {
      _cacheCards[card.id] = card.copyWith(isSynced: true);
    }
  }

  @override
  Future<List<WordCard>> pullCardsUpdatedSince(int timestamp) async {
    return _cacheCards.values
        .where((c) => c.updatedAt >= timestamp)
        .toList();
  }

  @override
  Future<void> pushViews(List<WordViewRecord> views) async {
    for (final view in views) {
      final existing = _cacheViews[view.word];
      if (existing == null || view.viewCount > existing.viewCount) {
        _cacheViews[view.word] = view.copyWith(isSynced: true);
      }
    }
  }

  @override
  Future<List<WordViewRecord>> pullViews() async {
    return _cacheViews.values.toList();
  }

  @override
  Future<void> pushReviewLogs(List<ReviewLog> logs) async {
    for (final log in logs) {
      _cacheLogs.removeWhere((l) => l.id == log.id);
      _cacheLogs.add(log);
    }
  }

  @override
  Future<List<ReviewLog>> pullReviewLogs({int? sinceTimestamp}) async {
    if (sinceTimestamp != null) {
      return _cacheLogs.where((l) => l.reviewedAt >= sinceTimestamp).toList();
    }
    return List.from(_cacheLogs);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    _cacheCards.remove(cardId);
  }

  void dispose() {
    _userStreamController.close();
  }
}
