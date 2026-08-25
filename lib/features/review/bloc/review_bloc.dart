import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/services/srs_engine.dart';

// --- Events ---
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadReviewSession extends ReviewEvent {
  const LoadReviewSession();
}

class RateCurrentCard extends ReviewEvent {
  final SrsRating rating;
  final int durationMs;

  const RateCurrentCard({required this.rating, this.durationMs = 0});

  @override
  List<Object?> get props => [rating, durationMs];
}

class UndoLastReview extends ReviewEvent {
  const UndoLastReview();
}

class DeleteCurrentCard extends ReviewEvent {
  const DeleteCurrentCard();
}

// --- State ---
abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSessionLoaded extends ReviewState {
  final List<WordCard> queue;
  final int currentIndex;
  final int newCardsCount;
  final int learningCardsCount;
  final int dueCardsCount;
  final List<WordCard> undoStack;
  final bool showAnswer;

  const ReviewSessionLoaded({
    required this.queue,
    this.currentIndex = 0,
    this.newCardsCount = 0,
    this.learningCardsCount = 0,
    this.dueCardsCount = 0,
    this.undoStack = const [],
    this.showAnswer = false,
  });

  WordCard? get currentCard {
    if (currentIndex < queue.length) return queue[currentIndex];
    return null;
  }

  bool get isSessionEmpty => queue.isEmpty || currentIndex >= queue.length;

  ReviewSessionLoaded copyWith({
    List<WordCard>? queue,
    int? currentIndex,
    int? newCardsCount,
    int? learningCardsCount,
    int? dueCardsCount,
    List<WordCard>? undoStack,
    bool? showAnswer,
  }) {
    return ReviewSessionLoaded(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      newCardsCount: newCardsCount ?? this.newCardsCount,
      learningCardsCount: learningCardsCount ?? this.learningCardsCount,
      dueCardsCount: dueCardsCount ?? this.dueCardsCount,
      undoStack: undoStack ?? this.undoStack,
      showAnswer: showAnswer ?? this.showAnswer,
    );
  }

  @override
  List<Object?> get props => [
        queue,
        currentIndex,
        newCardsCount,
        learningCardsCount,
        dueCardsCount,
        undoStack,
        showAnswer,
      ];
}

class ReviewSessionCompleted extends ReviewState {
  final int totalReviewed;
  const ReviewSessionCompleted({this.totalReviewed = 0});
  @override
  List<Object?> get props => [totalReviewed];
}

// --- BLoC ---
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final UserDataRepository repository;
  final SrsEngine srsEngine;

  ReviewBloc({
    required this.repository,
    this.srsEngine = const SrsEngine(),
  }) : super(ReviewInitial()) {
    on<LoadReviewSession>(_onLoadReviewSession);
    on<RateCurrentCard>(_onRateCurrentCard);
    on<UndoLastReview>(_onUndoLastReview);
    on<DeleteCurrentCard>(_onDeleteCurrentCard);
  }

  Future<void> _onLoadReviewSession(
    LoadReviewSession event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    final cards = await repository.watchReviewCards().first;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final queue = srsEngine.buildReviewQueue(allCards: cards, nowMs: nowMs);

    if (queue.isEmpty) {
      emit(const ReviewSessionCompleted(totalReviewed: 0));
      return;
    }

    final (newCount, learningCount, dueCount) = _calculateCounts(queue, nowMs);

    emit(ReviewSessionLoaded(
      queue: queue,
      currentIndex: 0,
      newCardsCount: newCount,
      learningCardsCount: learningCount,
      dueCardsCount: dueCount,
      undoStack: const [],
      showAnswer: false,
    ));
  }

  Future<void> _onRateCurrentCard(
    RateCurrentCard event,
    Emitter<ReviewState> emit,
  ) async {
    if (state is! ReviewSessionLoaded) return;
    final currentSession = state as ReviewSessionLoaded;
    final card = currentSession.currentCard;
    if (card == null) return;

    // 1. Submit review
    final previousState = card;
    final updatedCard = await repository.submitReview(
      card: card,
      rating: event.rating,
      durationMs: event.durationMs,
    );

    // 2. Update queue
    final newQueue = List<WordCard>.from(currentSession.queue);
    final newUndoStack = List<WordCard>.from(currentSession.undoStack)..add(previousState);

    // If rated Again, append back into queue for same-session drill
    if (event.rating == SrsRating.again) {
      newQueue.add(updatedCard);
    }

    final nextIndex = currentSession.currentIndex + 1;

    if (nextIndex >= newQueue.length) {
      emit(ReviewSessionCompleted(totalReviewed: newUndoStack.length));
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final (newCount, learningCount, dueCount) = _calculateCounts(
      newQueue.sublist(nextIndex),
      nowMs,
    );

    emit(currentSession.copyWith(
      queue: newQueue,
      currentIndex: nextIndex,
      newCardsCount: newCount,
      learningCardsCount: learningCount,
      dueCardsCount: dueCount,
      undoStack: newUndoStack,
      showAnswer: false,
    ));
  }

  Future<void> _onUndoLastReview(
    UndoLastReview event,
    Emitter<ReviewState> emit,
  ) async {
    if (state is! ReviewSessionLoaded) return;
    final currentSession = state as ReviewSessionLoaded;
    if (currentSession.undoStack.isEmpty) return;

    final lastCard = currentSession.undoStack.last;
    final newUndoStack = List<WordCard>.from(currentSession.undoStack)..removeLast();

    await repository.saveCard(lastCard);

    final prevIndex = currentSession.currentIndex > 0
        ? currentSession.currentIndex - 1
        : 0;

    final newQueue = List<WordCard>.from(currentSession.queue);
    if (prevIndex < newQueue.length) {
      newQueue[prevIndex] = lastCard;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final (newCount, learningCount, dueCount) = _calculateCounts(
      newQueue.sublist(prevIndex),
      nowMs,
    );

    emit(currentSession.copyWith(
      queue: newQueue,
      currentIndex: prevIndex,
      newCardsCount: newCount,
      learningCardsCount: learningCount,
      dueCardsCount: dueCount,
      undoStack: newUndoStack,
      showAnswer: false,
    ));
  }

  Future<void> _onDeleteCurrentCard(
    DeleteCurrentCard event,
    Emitter<ReviewState> emit,
  ) async {
    if (state is! ReviewSessionLoaded) return;
    final currentSession = state as ReviewSessionLoaded;
    final card = currentSession.currentCard;
    if (card == null) return;

    await repository.toggleReviewEnrollment(card: card);

    final newQueue = List<WordCard>.from(currentSession.queue)..removeAt(currentSession.currentIndex);

    if (currentSession.currentIndex >= newQueue.length) {
      emit(ReviewSessionCompleted(totalReviewed: currentSession.undoStack.length));
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final (newCount, learningCount, dueCount) = _calculateCounts(
      newQueue.sublist(currentSession.currentIndex),
      nowMs,
    );

    emit(currentSession.copyWith(
      queue: newQueue,
      newCardsCount: newCount,
      learningCardsCount: learningCount,
      dueCardsCount: dueCount,
      showAnswer: false,
    ));
  }

  (int, int, int) _calculateCounts(List<WordCard> cards, int nowMs) {
    int newCount = 0;
    int learningCount = 0;
    int dueCount = 0;

    for (final card in cards) {
      if (!card.isInReview) continue;
      final srs = card.srsData!;
      if (srs.stage == SrsStage.newCard) {
        newCount++;
      } else if (srs.stage == SrsStage.learning || srs.stage == SrsStage.relearning) {
        learningCount++;
      } else if (srs.dueAt <= nowMs) {
        dueCount++;
      }
    }

    return (newCount, learningCount, dueCount);
  }
}
