import 'dart:async';
import 'dart:developer';
import 'package:jisho_anki/core/data/datasources/local_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/remote_user_data_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_data.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/services/srs_engine.dart';

/// Offline-first repository coordinating local cache and remote synchronization.
class UserDataRepositoryImpl implements UserDataRepository {
  final LocalUserDataDataSource localDataSource;
  final RemoteUserDataDataSource remoteDataSource;
  final SrsEngine srsEngine;

  final StreamController<List<WordCard>> _allCardsController =
      StreamController<List<WordCard>>.broadcast();
  final StreamController<List<WordCard>> _favoritesController =
      StreamController<List<WordCard>>.broadcast();
  final StreamController<List<WordCard>> _reviewCardsController =
      StreamController<List<WordCard>>.broadcast();
  final StreamController<Map<String, WordViewRecord>> _viewsController =
      StreamController<Map<String, WordViewRecord>>.broadcast();
  final StreamController<List<WordCard>> _historyController =
      StreamController<List<WordCard>>.broadcast();

  bool _isSyncing = false;
  final Set<String> _locallyDeletedCardIds = {};

  UserDataRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.srsEngine = const SrsEngine(),
  });

  /// Initializes streams from local storage and begins background sync.
  Future<void> init() async {
    await _refreshCardsStream();
    await _refreshViewsStream();
    await _refreshHistoryStream();
    unawaited(syncWithRemote());
  }

  Future<void> _refreshCardsStream() async {
    final all = await localDataSource.getAllCards();
    final favorites = all.where((c) => c.isFavorite).toList();
    final reviews = all.where((c) => c.isInReview).toList();

    if (!_allCardsController.isClosed) _allCardsController.add(all);
    if (!_favoritesController.isClosed) _favoritesController.add(favorites);
    if (!_reviewCardsController.isClosed) _reviewCardsController.add(reviews);
  }

  Future<void> _refreshViewsStream() async {
    final views = await localDataSource.getAllViewRecords();
    final map = {for (final v in views) v.word: v};
    if (!_viewsController.isClosed) _viewsController.add(map);
  }

  Future<void> _refreshHistoryStream() async {
    final history = await localDataSource.getHistory();
    if (!_historyController.isClosed) _historyController.add(history);
  }

  @override
  Stream<List<WordCard>> watchAllCards() async* {
    yield await localDataSource.getAllCards();
    yield* _allCardsController.stream;
  }

  @override
  Stream<List<WordCard>> watchFavorites() async* {
    yield await localDataSource.getFavorites();
    yield* _favoritesController.stream;
  }

  @override
  Stream<List<WordCard>> watchReviewCards() async* {
    yield await localDataSource.getReviewCards();
    yield* _reviewCardsController.stream;
  }

  @override
  Stream<Map<String, WordViewRecord>> watchWordViews() async* {
    final views = await localDataSource.getAllViewRecords();
    yield {for (final v in views) v.word: v};
    yield* _viewsController.stream;
  }

  @override
  Stream<List<WordCard>> watchHistory() async* {
    yield await localDataSource.getHistory();
    yield* _historyController.stream;
  }

  @override
  Future<WordCard?> getCard(String id) => localDataSource.getCard(id);

  @override
  Future<void> saveCard(WordCard card) async {
    _locallyDeletedCardIds.remove(card.id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = card.copyWith(updatedAt: now, isSynced: false);
    await localDataSource.upsertCard(updated);
    await _refreshCardsStream();
    unawaited(syncWithRemote());
  }

  @override
  Future<void> deleteCard(String id) async {
    _locallyDeletedCardIds.add(id);
    await localDataSource.deleteCard(id);
    await _refreshCardsStream();
    try {
      await remoteDataSource.deleteCard(id);
    } catch (e) {
      log('UserDataRepository: Error deleting card remotely: $e');
    }
  }

  @override
  Future<void> toggleFavorite({required WordCard card}) async {
    final existing = await localDataSource.getCard(card.id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final newFavoriteStatus = existing != null ? !existing.isFavorite : true;

    final target = (existing ?? card).copyWith(
      isFavorite: newFavoriteStatus,
      updatedAt: now,
      isSynced: false,
    );

    // If no longer favorite and not in review, delete from user_cards
    if (!target.isFavorite && !target.isInReview) {
      await deleteCard(target.id);
    } else {
      _locallyDeletedCardIds.remove(target.id);
      await localDataSource.upsertCard(target);
      await _refreshCardsStream();
      unawaited(syncWithRemote());
    }
  }

  @override
  Future<void> toggleReviewEnrollment({required WordCard card}) async {
    final existing = await localDataSource.getCard(card.id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentlyInReview = existing?.isInReview ?? false;

    if (currentlyInReview) {
      // Remove from review
      final target = (existing ?? card).copyWith(
        clearSrsData: true,
        updatedAt: now,
        isSynced: false,
      );

      if (!target.isFavorite) {
        await deleteCard(target.id);
      } else {
        await localDataSource.upsertCard(target);
        await _refreshCardsStream();
        unawaited(syncWithRemote());
      }
    } else {
      // Enroll into review
      _locallyDeletedCardIds.remove(card.id);
      final target = (existing ?? card).copyWith(
        srsData: SrsData.initial(),
        updatedAt: now,
        isSynced: false,
      );
      await localDataSource.upsertCard(target);
      await _refreshCardsStream();
      unawaited(syncWithRemote());
    }
  }

  @override
  Future<WordCard> submitReview({
    required WordCard card,
    required SrsRating rating,
    int durationMs = 0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentSrs = card.srsData ?? SrsData.initial();
    final nextSrs = srsEngine.calculateNextState(
      current: currentSrs,
      rating: rating,
      nowMs: now,
    );

    final updatedCard = card.copyWith(
      srsData: nextSrs,
      updatedAt: now,
      isSynced: false,
    );

    await localDataSource.upsertCard(updatedCard);

    // Record review log
    final logId = 'log_${now}_${card.id}';
    final logItem = ReviewLog(
      id: logId,
      cardId: card.id,
      rating: rating,
      reviewDurationMs: durationMs,
      reviewedAt: now,
      previousIntervalMs: currentSrs.intervalMs,
      newIntervalMs: nextSrs.intervalMs,
      previousEase: currentSrs.easeFactor,
      newEase: nextSrs.easeFactor,
      isSynced: false,
    );

    await localDataSource.insertReviewLog(logItem);
    await _refreshCardsStream();
    unawaited(syncWithRemote());

    return updatedCard;
  }

  @override
  Future<void> revertReview({
    required WordCard previousCardState,
    required String logIdToDelete,
  }) async {
    await localDataSource.upsertCard(previousCardState);
    await localDataSource.deleteReviewLog(logIdToDelete);
    await _refreshCardsStream();
  }

  @override
  Future<void> recordWordView(String word) async {
    await localDataSource.recordView(word);
    await _refreshViewsStream();
    unawaited(syncWithRemote());
  }

  @override
  Future<int> getWordViewCount(String word) async {
    final record = await localDataSource.getViewRecord(word);
    return record?.viewCount ?? 0;
  }

  @override
  Future<void> addHistory(WordCard card) async {
    await localDataSource.addHistory(card);
    await _refreshHistoryStream();
  }

  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
    await _refreshHistoryStream();
  }

  @override
  Future<void> removeHistory(String id) async {
    await localDataSource.deleteHistory(id);
    await _refreshHistoryStream();
  }

  @override
  Future<UserStudyStats> getStudyStats() async {
    final cards = await localDataSource.getReviewCards();
    final logs = await localDataSource.getReviewLogs();
    return srsEngine.computeStats(
      cards: cards,
      reviewLogs: logs,
      now: DateTime.now(),
    );
  }

  @override
  Future<void> syncWithRemote() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      // 1. Push unsynced cards
      final unsyncedCards = await localDataSource.getUnsyncedCards();
      if (unsyncedCards.isNotEmpty) {
        await remoteDataSource.pushCards(unsyncedCards);
        await localDataSource.markCardsSynced(unsyncedCards.map((c) => c.id).toList());
      }

      // 2. Push unsynced views
      final unsyncedViews = await localDataSource.getUnsyncedViews();
      if (unsyncedViews.isNotEmpty) {
        await remoteDataSource.pushViews(unsyncedViews);
        await localDataSource.markViewsSynced(unsyncedViews.map((v) => v.word).toList());
      }

      // 3. Push unsynced review logs
      final unsyncedLogs = await localDataSource.getUnsyncedReviewLogs();
      if (unsyncedLogs.isNotEmpty) {
        await remoteDataSource.pushReviewLogs(unsyncedLogs);
        await localDataSource.markReviewLogsSynced(unsyncedLogs.map((l) => l.id).toList());
      }

      // 4. Pull remote updates (LWW merge)
      final remoteCards = await remoteDataSource.pullCardsUpdatedSince(0);
      for (final remoteCard in remoteCards) {
        if (_locallyDeletedCardIds.contains(remoteCard.id)) {
          // Card was deleted locally, do not resurrect
          await remoteDataSource.deleteCard(remoteCard.id);
          continue;
        }
        final localCard = await localDataSource.getCard(remoteCard.id);
        if (localCard == null || remoteCard.updatedAt > localCard.updatedAt) {
          await localDataSource.upsertCard(remoteCard.copyWith(isSynced: true));
        }
      }

      // 5. Pull remote views
      final remoteViews = await remoteDataSource.pullViews();
      for (final remoteView in remoteViews) {
        final localView = await localDataSource.getViewRecord(remoteView.word);
        if (localView == null || remoteView.viewCount > localView.viewCount) {
          await localDataSource.recordView(remoteView.word, timestamp: remoteView.lastViewedAt);
        }
      }

      await _refreshCardsStream();
      await _refreshViewsStream();
    } catch (e) {
      log('UserDataRepository: Sync error (offline / network error): $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _allCardsController.close();
    _favoritesController.close();
    _reviewCardsController.close();
    _viewsController.close();
    _historyController.close();
  }
}
