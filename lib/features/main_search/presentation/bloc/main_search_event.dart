part of 'main_search_bloc.dart';

sealed class MainSearchEvent extends Equatable {
  const MainSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchForPhraseEvent extends MainSearchEvent {
  final String phrase;
  const SearchForPhraseEvent(this.phrase);
}

class SearchForGrammarPointEvent extends MainSearchEvent {
  final String phrase;
  const SearchForGrammarPointEvent(this.phrase);
}

class SearchForLocalizedGlossEvent extends MainSearchEvent {
  final String phrase;
  const SearchForLocalizedGlossEvent(this.phrase);
}

class SearchForHanVietEvent extends MainSearchEvent {
  final String phrase;
  const SearchForHanVietEvent(this.phrase);
}

class SearchForJishoDefinitionEvent extends MainSearchEvent {
  final String phrase;
  const SearchForJishoDefinitionEvent(this.phrase);
}

class TriggerAnimationEvent extends MainSearchEvent {}

class ExpandLlmTileEvent extends MainSearchEvent {
  final bool expanded;
  const ExpandLlmTileEvent(this.expanded);
}
