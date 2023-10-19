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
import '../../../../models/vietnamese_definition.dart';

part 'main_search_event.dart';
part 'main_search_state.dart';

class MainSearchBloc extends Bloc<MainSearchEvent, MainSearchState> {
  final SearchJishoForPhrase searchJishoForPhrase;
  final LookForVietnameseDefinition lookForVietnameseDefinition;
  final LookupHanVietReading lookupHanVietReading;

  MainSearchBloc({
    required this.searchJishoForPhrase,
    required this.lookForVietnameseDefinition,
    required this.lookupHanVietReading,
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

    if (isAppInVietnamese) {
      final resultEither = await lookForVietnameseDefinition.call(event.phrase);
      resultEither.fold(
          (failure) => emit(MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              )), (definitionList) async {
        for (var definition in definitionList) {
          final hanVietResultEither =
              await lookupHanVietReading.call(definition.word);
          hanVietResultEither.fold(
            (l) => null,
            (hanViet) => wordToHanVietMap[definition.word] = hanViet,
          );
        }
        emit(MainSearchVNLoadedState(
          state.data.copyWith(
            vnDictQuery: definitionList,
            wordToHanVietMap: wordToHanVietMap,
          ),
        ));
      });
    }

    final jishoResultEither = await searchJishoForPhrase.call(event.phrase);
    jishoResultEither.fold(
        (failure) => emit(
              MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              ),
            ),
        (jishoDefinitionList) => emit(MainSearchAllLoadedState(state.data.copyWith(
              jishoDefinitionList: jishoDefinitionList,
            ))));
  }
}
