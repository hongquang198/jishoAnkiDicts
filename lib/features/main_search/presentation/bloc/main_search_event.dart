part of 'main_search_bloc.dart';

sealed class MainSearchEvent extends Equatable {
  const MainSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchForPhraseEvent extends MainSearchEvent {
  final String phrase;
  SearchForPhraseEvent(this.phrase);
}
