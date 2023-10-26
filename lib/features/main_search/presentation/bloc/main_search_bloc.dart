import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_for_vietnamese_definition.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_han_viet_reading.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/search_jisho_for_phrase.dart';
import 'package:collection/collection.dart';

import '../../../../injection.dart';
import '../../../../models/grammar_point.dart';
import '../../../../models/vietnamese_definition.dart';
import '../../domain/use_cases/look_up_grammar_point.dart';

part 'main_search_event.dart';
part 'main_search_state.dart';

class MainSearchBloc extends Bloc<MainSearchEvent, MainSearchState> {
  final SearchJishoForPhrase searchJishoForPhrase;
  final LookForVietnameseDefinition lookForVietnameseDefinition;
  final LookupHanVietReading lookupHanVietReading;
  final LookUpGrammarPoint lookupGrammarPoint;

  MainSearchBloc({
    required this.searchJishoForPhrase,
    required this.lookForVietnameseDefinition,
    required this.lookupHanVietReading,
    required this.lookupGrammarPoint,
  }) : super(MainSearchLoadingState(const MainSearchStateData())) {
    on<SearchForPhraseEvent>(_onSearchForPhrase);
    on<SearchForGrammarPointEvent>(_onSearchForGrammarPoint);
    on<SearchForVnDefinitionEvent>(_onSearchForVnDefinition);
    on<SearchForHanVietEvent>(_onSearchForHanViet);
    on<SearchForJishoDefinitionEvent>(_onSearchForJishoDefinition);
  }

  FutureOr<void> _onSearchForPhrase(
      SearchForPhraseEvent event, Emitter<MainSearchState> emit) async {
    final isAppInVietnamese =
        getIt<SharedPref>().isAppInVietnamese;
    emit(MainSearchLoadingState(state.data.copyWith(
      isAppInVietnamese: isAppInVietnamese,
    )));

    add(SearchForGrammarPointEvent(event.phrase));
    if (isAppInVietnamese) {
      add(SearchForVnDefinitionEvent(event.phrase));
    }
    add(SearchForJishoDefinitionEvent(event.phrase));
  }

  FutureOr<void> _onSearchForGrammarPoint(
      SearchForGrammarPointEvent event, Emitter<MainSearchState> emit) async {
    final grammarResult = await lookupGrammarPoint.call(event.phrase);
    grammarResult.fold(
        (failure) => emit(MainSearchFailureState(
              state.data,
              failureMessage: failure.properties.toString(),
            )),
        (grammarList) => emit(MainSearchLoadedState(state.data.copyWith(
              grammarPointList: grammarList,
            ))));
  }

  FutureOr<void> _onSearchForVnDefinition(
      SearchForVnDefinitionEvent event, Emitter<MainSearchState> emit) async {
      final vnDefinitionEither = await lookForVietnameseDefinition.call(event.phrase);
      vnDefinitionEither.fold(
          (failure) => emit(MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              )), (definitionList) {
        emit(MainSearchLoadedState(
          state.data.copyWith(
            vnDictQuery: definitionList,
          ),
        ));
      });
      add(SearchForHanVietEvent(event.phrase));
  }

  FutureOr<void> _onSearchForHanViet(
      SearchForHanVietEvent event, Emitter<MainSearchState> emit) async {
    Map<String, List<String>> wordToHanVietMap = {}
      ..addAll(state.data.wordToHanVietMap);
    for (var definition in state.data.vnDictQuery) {
      final hanVietResultEither =
          await lookupHanVietReading.call(definition.word);
      hanVietResultEither.fold(
        (l) => null,
        (hanViet) {
          wordToHanVietMap[definition.word] = hanViet;
          emit(MainSearchLoadedState(
              state.data.copyWith(wordToHanVietMap: wordToHanVietMap)));
        },
      );
    }
    emit(MainSearchLoadedState(
        state.data.copyWith(wordToHanVietMap: wordToHanVietMap)));
  }

  FutureOr<void> _onSearchForJishoDefinition(
      SearchForJishoDefinitionEvent event,
      Emitter<MainSearchState> emit) async {
    final jishoResultEither = await searchJishoForPhrase.call(event.phrase);
    jishoResultEither.fold(
        (failure) => emit(
              MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              ),
            ), (jishoDefinitionList) {
      emit(MainSearchJishoLoadedState(state.data.copyWith(
        jishoDefinitionList: jishoDefinitionList,
      )));
    });

    if (state.data.isAppInVietnamese) {
      Map<String, List<String>> wordToHanVietMap = {}
        ..addAll(state.data.wordToHanVietMap);
      for (var definition in state.data.jishoDefinitionList.sublist(0, 5)) {
        final hanVietResultEither =
            await lookupHanVietReading.call(definition.japaneseWord);
        hanVietResultEither.fold(
          (l) => null,
          (hanViet) {
            wordToHanVietMap[definition.japaneseWord] = hanViet;
            emit(MainSearchLoadedState(
                state.data.copyWith(wordToHanVietMap: wordToHanVietMap)));
          },
        );
      }
    }
  }
}
