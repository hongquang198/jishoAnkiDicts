import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:japanese_ocr/core/data/datasources/shared_pref.dart';
import 'package:japanese_ocr/features/main_search/domain/entities/jisho_definition.dart';
import 'package:japanese_ocr/features/main_search/domain/use_cases/look_for_vietnamese_definition.dart';
import 'package:japanese_ocr/features/main_search/domain/use_cases/look_up_han_viet_reading.dart';
import 'package:japanese_ocr/features/main_search/domain/use_cases/search_jisho_for_phrase.dart';
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
  }

  FutureOr<void> _onSearchForPhrase(
      SearchForPhraseEvent event, Emitter<MainSearchState> emit) async {
    Map<String, List<String>> wordToHanVietMap = {};
    final isAppInVietnamese =
        getIt<SharedPref>().isAppInVietnamese;

    emit(MainSearchLoadingState(
        state.data.copyWith(
      isAppInVietnamese: isAppInVietnamese,
      vnDictQuery: [],
      jishoDefinitionList: [],
    )));

    final grammarResult = await lookupGrammarPoint.call(event.phrase);
    grammarResult.fold(
        (failure) => emit(MainSearchFailureState(
              state.data,
              failureMessage: failure.properties.toString(),
            )),
        (grammarList) => emit(MainSearchGrammarLoadedState(state.data.copyWith(
              grammarPointList: grammarList,
            ))));

    if (isAppInVietnamese) {
      final resultEither = await lookForVietnameseDefinition.call(event.phrase);
      resultEither.fold(
          (failure) => emit(MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              )), (definitionList) {
        emit(MainSearchVNLoadedState(
          state.data.copyWith(
            vnDictQuery: definitionList,
            wordToHanVietMap: wordToHanVietMap,
          ),
        ));
      });
    }

    for (var definition in state.data.vnDictQuery) {
      final hanVietResultEither =
          await lookupHanVietReading.call(definition.word);
      hanVietResultEither.fold(
        (l) => null,
        (hanViet) => wordToHanVietMap[definition.word] = hanViet,
      );
    }
    emit(MainSearchVNLoadedState(
        state.data.copyWith(wordToHanVietMap: wordToHanVietMap)));

    final jishoResultEither = await searchJishoForPhrase.call(event.phrase);
    jishoResultEither.fold(
        (failure) => emit(
              MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              ),
            ), (jishoDefinitionList) {
      emit(MainSearchAllLoadedState(state.data.copyWith(
        jishoDefinitionList: jishoDefinitionList,
      )));
    });

    for (var definition in state.data.jishoDefinitionList.sublist(0, 5)) {
      final hanVietResultEither =
          await lookupHanVietReading.call(definition.japaneseWord);
      hanVietResultEither.fold(
        (l) => null,
        (hanViet) {
          wordToHanVietMap[definition.japaneseWord] = hanViet;
          emit(MainSearchAllLoadedState(
              state.data.copyWith(wordToHanVietMap: wordToHanVietMap)));
        },
      );
    }
  }
}
