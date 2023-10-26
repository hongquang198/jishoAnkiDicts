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

class SearchForGrammarPointEvent extends MainSearchEvent {
  final String phrase;
  SearchForGrammarPointEvent(this.phrase);
}

class SearchForVnDefinitionEvent extends MainSearchEvent {
  final String phrase;
  SearchForVnDefinitionEvent(this.phrase);
}

class SearchForHanVietEvent extends MainSearchEvent {
  final String phrase;
  SearchForHanVietEvent(this.phrase);
}

class SearchForJishoDefinitionEvent extends MainSearchEvent {
  final String phrase;
  SearchForJishoDefinitionEvent(this.phrase);
}