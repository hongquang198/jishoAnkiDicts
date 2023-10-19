
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';

import '../../../../../models/vietnamese_definition.dart';
import '../../../domain/entities/jisho_definition.dart';
import '../mixins/get_vietnamese_definition_mixin.dart';
import 'search_result_tile.dart';

class ListSearchResultVN extends StatelessWidget {
  const ListSearchResultVN({
    super.key,
    required this.vnDictQuery,
  });

  final List<VietnameseDefinition> vnDictQuery;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              thickness: 0.4,
            ),
        itemCount: vnDictQuery.length,
        itemBuilder: (BuildContext context, int index) {
          SearchResultTile searchResultTileOldWaiting =
              _getSearchResultTileOldWaiting(context, index: index);
          return BlocBuilder<MainSearchBloc, MainSearchState>(
              builder: (context, state) {
            SearchResultTile searchResultTileWithVnFinished =
                _getSearchResultTileWithVnFinished(
              context,
              index: index,
              hanViet:
                  _getHanViet(state, index),
            );
            return switch (state) {
              MainSearchLoadingState() => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              MainSearchAllLoadedState(data: var data)
                  when data.jishoDefinitionList.any((element) =>
                      element.japaneseWord == vnDictQuery[index].word) =>
                _getSearchResultTileVnEnFinished(
                  context,
                  index: index,
                  jishoDefinition: data.jishoDefinitionList.firstWhere(
                      (element) =>
                          element.japaneseWord == vnDictQuery[index].word),
                  hanViet: _getHanViet(state, index),
                ),
              MainSearchVNLoadedState(data: var data)
                  when data.vnDictQuery.isNotEmpty || vnDictQuery.isNotEmpty =>
                searchResultTileWithVnFinished,
              MainSearchFailureState() => const SizedBox.shrink(),
              _ => searchResultTileOldWaiting,
            };
          });
        });
  }

  List<String> _getHanViet(MainSearchState state, int index) =>
      state.data.wordToHanVietMap[vnDictQuery[index].word] ?? [];

  SearchResultTile _getSearchResultTileOldWaiting(
    BuildContext context, {
    required int index,
    List<String> hanViet = const [],
  }) {
    return SearchResultTile(
      loadingDefinition: true,
      hanViet: hanViet,
      vnDefinition: vnDictQuery[index],
      // ignore: missing_return
    );
  }

  SearchResultTile _getSearchResultTileWithVnFinished(
    BuildContext context, {
    required int index,
    List<String> hanViet = const [],
  }) {
    return SearchResultTile(
      loadingDefinition: false,
      hanViet: hanViet,
      vnDefinition: vnDictQuery[index],
    );
  }

  SearchResultTile _getSearchResultTileVnEnFinished(
    BuildContext context, {
    required int index,
    JishoDefinition? jishoDefinition,
    List<String> hanViet = const [],
  }) {
    return SearchResultTile(
      loadingDefinition: false,
      jishoDefinition: jishoDefinition,
      hanViet: hanViet,
      vnDefinition: vnDictQuery[index],
    );
  }
}

class ListSearchResultAllLoaded extends StatelessWidget
    with GetVietnameseDefinitionMixin {
  const ListSearchResultAllLoaded({
    required this.jishoDefinitionList,
    required this.wordToHanVietMap,
    super.key,
  });

  final List<JishoDefinition> jishoDefinitionList;
  final Map<String, List<String>> wordToHanVietMap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              thickness: 0.4,
            ),
        itemCount: jishoDefinitionList.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
              future: getVietnameseDefinition(jishoDefinitionList[index].japaneseWord),
              builder: (context, vnSnapshot) {
                if (vnSnapshot.connectionState == ConnectionState.done &&
                    vnSnapshot.data != null) {
                  return SearchResultTile(
                    jishoDefinition:
                        jishoDefinitionList[index],
                    hanViet: wordToHanVietMap[jishoDefinitionList[index].japaneseWord] ?? [],
                    vnDefinition: vnSnapshot.data,
                  );
                } else
                  return SearchResultTile(
                    jishoDefinition: jishoDefinitionList[index],
                    hanViet: wordToHanVietMap[jishoDefinitionList[index].japaneseWord] ?? [],
                  );
              });
        });
  }
}
