import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

// --- Events ---
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

class _UpdateHistoryEvent extends HistoryEvent {
  final List<WordCard> history;
  const _UpdateHistoryEvent(this.history);
  @override
  List<Object?> get props => [history];
}

class SearchHistory extends HistoryEvent {
  final String query;
  const SearchHistory(this.query);
  @override
  List<Object?> get props => [query];
}

class RemoveHistoryItem extends HistoryEvent {
  final String id;
  const RemoveHistoryItem(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearAllHistory extends HistoryEvent {
  const ClearAllHistory();
}

// --- State ---
abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<WordCard> allHistory;
  final List<WordCard> filteredHistory;
  final String searchQuery;

  const HistoryLoaded({
    required this.allHistory,
    required this.filteredHistory,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allHistory, filteredHistory, searchQuery];
}

// --- BLoC ---
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final UserDataRepository repository;
  StreamSubscription? _historySubscription;

  HistoryBloc({required this.repository}) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<_UpdateHistoryEvent>(_onUpdateHistory);
    on<SearchHistory>(_onSearchHistory);
    on<RemoveHistoryItem>(_onRemoveHistoryItem);
    on<ClearAllHistory>(_onClearAllHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    await _historySubscription?.cancel();
    _historySubscription = repository.watchHistory().listen((history) {
      add(_UpdateHistoryEvent(history));
    });

    final history = await repository.watchHistory().first;
    emit(HistoryLoaded(
      allHistory: history,
      filteredHistory: history,
      searchQuery: '',
    ));
  }

  void _onUpdateHistory(
    _UpdateHistoryEvent event,
    Emitter<HistoryState> emit,
  ) {
    final query = state is HistoryLoaded ? (state as HistoryLoaded).searchQuery : '';
    final filtered = _filterList(event.history, query);
    emit(HistoryLoaded(
      allHistory: event.history,
      filteredHistory: filtered,
      searchQuery: query,
    ));
  }

  void _onSearchHistory(
    SearchHistory event,
    Emitter<HistoryState> emit,
  ) {
    if (state is! HistoryLoaded) return;
    final current = state as HistoryLoaded;
    final filtered = _filterList(current.allHistory, event.query);

    emit(HistoryLoaded(
      allHistory: current.allHistory,
      filteredHistory: filtered,
      searchQuery: event.query,
    ));
  }

  List<WordCard> _filterList(List<WordCard> list, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((card) {
      return card.word.toLowerCase().contains(q) ||
          card.reading.toLowerCase().contains(q) ||
          card.vietnameseDefinition.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _onRemoveHistoryItem(
    RemoveHistoryItem event,
    Emitter<HistoryState> emit,
  ) async {
    await repository.removeHistory(event.id);
  }

  Future<void> _onClearAllHistory(
    ClearAllHistory event,
    Emitter<HistoryState> emit,
  ) async {
    await repository.clearHistory();
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}
