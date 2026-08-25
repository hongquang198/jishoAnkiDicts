import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

// --- Events ---
abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();
}

class _UpdateFavoritesEvent extends FavoriteEvent {
  final List<WordCard> favorites;
  const _UpdateFavoritesEvent(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class SearchFavorites extends FavoriteEvent {
  final String query;
  const SearchFavorites(this.query);
  @override
  List<Object?> get props => [query];
}

class RemoveFavoriteItem extends FavoriteEvent {
  final WordCard card;
  const RemoveFavoriteItem(this.card);
  @override
  List<Object?> get props => [card];
}

// --- State ---
abstract class FavoriteState extends Equatable {
  const FavoriteState();
  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<WordCard> allFavorites;
  final List<WordCard> filteredFavorites;
  final String searchQuery;

  const FavoriteLoaded({
    required this.allFavorites,
    required this.filteredFavorites,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allFavorites, filteredFavorites, searchQuery];
}

// --- BLoC ---
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final UserDataRepository repository;
  StreamSubscription? _favoritesSubscription;

  FavoriteBloc({required this.repository}) : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<_UpdateFavoritesEvent>(_onUpdateFavorites);
    on<SearchFavorites>(_onSearchFavorites);
    on<RemoveFavoriteItem>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = repository.watchFavorites().listen((favorites) {
      add(_UpdateFavoritesEvent(favorites));
    });

    final favorites = await repository.watchFavorites().first;
    emit(FavoriteLoaded(
      allFavorites: favorites,
      filteredFavorites: favorites,
      searchQuery: '',
    ));
  }

  void _onUpdateFavorites(
    _UpdateFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) {
    final query = state is FavoriteLoaded ? (state as FavoriteLoaded).searchQuery : '';
    final filtered = _filterList(event.favorites, query);
    emit(FavoriteLoaded(
      allFavorites: event.favorites,
      filteredFavorites: filtered,
      searchQuery: query,
    ));
  }

  void _onSearchFavorites(
    SearchFavorites event,
    Emitter<FavoriteState> emit,
  ) {
    if (state is! FavoriteLoaded) return;
    final current = state as FavoriteLoaded;
    final filtered = _filterList(current.allFavorites, event.query);

    emit(FavoriteLoaded(
      allFavorites: current.allFavorites,
      filteredFavorites: filtered,
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

  Future<void> _onRemoveFavorite(
    RemoveFavoriteItem event,
    Emitter<FavoriteState> emit,
  ) async {
    await repository.toggleFavorite(card: event.card);
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
