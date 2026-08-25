import 'dart:async';
import 'package:jisho_anki/core/data/datasources/remote_user_data_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// In-memory implementation of [RemoteUserDataDataSource] for testing and offline/standalone mode.
class InMemoryRemoteUserDataDataSource implements RemoteUserDataDataSource {
  String? _userId = 'local_user_default';
  final StreamController<String?> _userStreamController =
      StreamController<String?>.broadcast();

  final Map<String, WordCard> _remoteCards = {};
  final Map<String, WordViewRecord> _remoteViews = {};
  final List<ReviewLog> _remoteLogs = [];

  InMemoryRemoteUserDataDataSource({String? initialUserId}) {
    if (initialUserId != null) _userId = initialUserId;
  }

  @override
  String? get currentUserId => _userId;

  @override
  Stream<String?> watchUserId() => _userStreamController.stream;

  @override
  Future<void> signInAnonymously() async {
    _userId = 'anon_${DateTime.now().millisecondsSinceEpoch}';
    _userStreamController.add(_userId);
  }

  @override
  Future<void> pushCards(List<WordCard> cards) async {
    for (final card in cards) {
      _remoteCards[card.id] = card.copyWith(isSynced: true);
    }
  }

  @override
  Future<List<WordCard>> pullCardsUpdatedSince(int timestamp) async {
    return _remoteCards.values
        .where((c) => c.updatedAt >= timestamp)
        .toList();
  }

  @override
  Future<void> pushViews(List<WordViewRecord> views) async {
    for (final view in views) {
      final existing = _remoteViews[view.word];
      if (existing == null || view.viewCount > existing.viewCount) {
        _remoteViews[view.word] = view.copyWith(isSynced: true);
      }
    }
  }

  @override
  Future<List<WordViewRecord>> pullViews() async {
    return _remoteViews.values.toList();
  }

  @override
  Future<void> pushReviewLogs(List<ReviewLog> logs) async {
    for (final log in logs) {
      _remoteLogs.removeWhere((l) => l.id == log.id);
      _remoteLogs.add(log);
    }
  }

  @override
  Future<List<ReviewLog>> pullReviewLogs({int? sinceTimestamp}) async {
    if (sinceTimestamp != null) {
      return _remoteLogs.where((l) => l.reviewedAt >= sinceTimestamp).toList();
    }
    return List.from(_remoteLogs);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    _remoteCards.remove(cardId);
  }

  void dispose() {
    _userStreamController.close();
  }
}
