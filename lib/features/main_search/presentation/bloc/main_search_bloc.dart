import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:japanese_ocr/core/data/datasources/sharedPref.dart';
import 'package:japanese_ocr/features/main_search/domain/entities/jisho_definition.dart';
import 'package:japanese_ocr/features/main_search/domain/usecases/look_for_vietnamese_definition.dart';
import 'package:japanese_ocr/features/main_search/domain/usecases/search_jisho_for_phrase.dart';

import 'package:collection/collection.dart';

import '../../../../core/domain/entities/dictionary.dart';
import '../../../../injection.dart';
import '../../../../models/vietnameseDefinition.dart';

part 'main_search_event.dart';
part 'main_search_state.dart';

class MainSearchBloc extends Bloc<MainSearchEvent, MainSearchState> {
  final SearchJishoForPhrase searchJishoForPhrase;
  final LookForVietnameseDefinition lookForVietnameseDefinition;
  final Dictionary dictionary;

  MainSearchBloc({
    required this.searchJishoForPhrase,
    required this.lookForVietnameseDefinition,
    required this.dictionary,
  }) : super(MainSeachLoadingState(const MainSearchStateData())) {
    on<SearchForPhraseEvent>(_onSearchForPhrase);
  }

  FutureOr<void> _onSearchForPhrase(
      SearchForPhraseEvent event, Emitter<MainSearchState> emit) async {
    emit(MainSeachLoadingState(state.data));
    final isAppInVietnamese =
        getIt<SharedPref>().prefs.getString('language') == ('Tiếng Việt');

    emit(MainSeachLoadingState(
        state.data.copyWith(isAppInVietnamese: isAppInVietnamese)));

    if (isAppInVietnamese) {
      final resultEither = await lookForVietnameseDefinition.call(event.phrase);
      resultEither.fold(
          (failure) => emit(MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              )), (definitionList) {
        emit(MainSearchLoadedState(
          state.data.copyWith(vnDictQuery: definitionList),
        ));
      });
    }

    final resultEither = await searchJishoForPhrase.call(event.phrase);

    resultEither.fold(
        (failure) => emit(
              MainSearchFailureState(
                state.data,
                failureMessage: failure.properties.toString(),
              ),
            ),
        (jishoDefinitionList) => emit(MainSearchLoadedState(state.data.copyWith(
              jishoDefinitionList: jishoDefinitionList,
            ))));
  }
}