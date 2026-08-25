import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

// --- Events ---
abstract class WordInteractionEvent extends Equatable {
  const WordInteractionEvent();
  @override
  List<Object?> get props => [];
}

class WatchWordInteraction extends WordInteractionEvent {
  final String word;
  const WatchWordInteraction(this.word);
  @override
  List<Object?> get props => [word];
}

class _UpdateCardStateEvent extends WordInteractionEvent {
  final bool isFavorite;
  final bool isInReview;
  const _UpdateCardStateEvent({required this.isFavorite, required this.isInReview});
  @override
  List<Object?> get props => [isFavorite, isInReview];
}

class _UpdateViewStateEvent extends WordInteractionEvent {
  final int viewCount;
  const _UpdateViewStateEvent(this.viewCount);
  @override
  List<Object?> get props => [viewCount];
}

class ToggleWordFavoriteEvent extends WordInteractionEvent {
  final WordCard card;
  const ToggleWordFavoriteEvent(this.card);
  @override
  List<Object?> get props => [card];
}

class ToggleWordReviewEvent extends WordInteractionEvent {
  final WordCard card;
  const ToggleWordReviewEvent(this.card);
  @override
  List<Object?> get props => [card];
}

class RecordWordViewEvent extends WordInteractionEvent {
  final String word;
  const RecordWordViewEvent(this.word);
  @override
  List<Object?> get props => [word];
}

// --- State ---
class WordInteractionState extends Equatable {
  final String word;
  final bool isFavorite;
  final bool isInReview;
  final int viewCount;
  final bool isLoading;

  const WordInteractionState({
    this.word = '',
    this.isFavorite = false,
    this.isInReview = false,
    this.viewCount = 0,
    this.isLoading = false,
  });

  WordInteractionState copyWith({
    String? word,
    bool? isFavorite,
    bool? isInReview,
    int? viewCount,
    bool? isLoading,
  }) {
    return WordInteractionState(
      word: word ?? this.word,
      isFavorite: isFavorite ?? this.isFavorite,
      isInReview: isInReview ?? this.isInReview,
      viewCount: viewCount ?? this.viewCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [word, isFavorite, isInReview, viewCount, isLoading];
}

// --- BLoC ---
class WordInteractionBloc
    extends Bloc<WordInteractionEvent, WordInteractionState> {
  final UserDataRepository repository;
  StreamSubscription? _cardsSubscription;
  StreamSubscription? _viewsSubscription;

  WordInteractionBloc({required this.repository})
      : super(const WordInteractionState()) {
    on<WatchWordInteraction>(_onWatchWordInteraction);
    on<_UpdateCardStateEvent>((event, emit) {
      emit(state.copyWith(
        isFavorite: event.isFavorite,
        isInReview: event.isInReview,
      ));
    });
    on<_UpdateViewStateEvent>((event, emit) {
      emit(state.copyWith(viewCount: event.viewCount));
    });
    on<ToggleWordFavoriteEvent>(_onToggleFavorite);
    on<ToggleWordReviewEvent>(_onToggleReview);
    on<RecordWordViewEvent>(_onRecordView);
  }

  Future<void> _onWatchWordInteraction(
    WatchWordInteraction event,
    Emitter<WordInteractionState> emit,
  ) async {
    emit(state.copyWith(word: event.word, isLoading: true));

    final card = await repository.getCard(event.word);
    final count = await repository.getWordViewCount(event.word);

    emit(state.copyWith(
      word: event.word,
      isFavorite: card?.isFavorite ?? false,
      isInReview: card?.isInReview ?? false,
      viewCount: count,
      isLoading: false,
    ));

    await _cardsSubscription?.cancel();
    _cardsSubscription = repository.watchAllCards().listen((cards) {
      final found = cards.where((c) => c.id == event.word || c.word == event.word || c.slug == event.word).firstOrNull;
      add(_UpdateCardStateEvent(
        isFavorite: found?.isFavorite ?? false,
        isInReview: found?.isInReview ?? false,
      ));
    });

    await _viewsSubscription?.cancel();
    _viewsSubscription = repository.watchWordViews().listen((views) {
      final viewRecord = views[event.word];
      if (viewRecord != null) {
        add(_UpdateViewStateEvent(viewRecord.viewCount));
      }
    });
  }

  Future<void> _onToggleFavorite(
    ToggleWordFavoriteEvent event,
    Emitter<WordInteractionState> emit,
  ) async {
    await repository.toggleFavorite(card: event.card);
  }

  Future<void> _onToggleReview(
    ToggleWordReviewEvent event,
    Emitter<WordInteractionState> emit,
  ) async {
    await repository.toggleReviewEnrollment(card: event.card);
  }

  Future<void> _onRecordView(
    RecordWordViewEvent event,
    Emitter<WordInteractionState> emit,
  ) async {
    await repository.recordWordView(event.word);
  }

  @override
  Future<void> close() {
    _cardsSubscription?.cancel();
    _viewsSubscription?.cancel();
    return super.close();
  }
}
