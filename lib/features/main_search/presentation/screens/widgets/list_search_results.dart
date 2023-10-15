
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';

import '../../../../../models/vietnamese_definition.dart';
import '../../../../../services/kanji_helper.dart';
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
              _getSearchResultTileOldWaiting(index, context);
          return BlocBuilder<MainSearchBloc, MainSearchState>(
              builder: (context, state) {
            SearchResultTile searchResultTileWithVnFinished =
                _getSearchResultTileWithVnFinished(index, context);
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
                    data.jishoDefinitionList.firstWhere((element) =>
                        element.japaneseWord == vnDictQuery[index].word),
                    index,
                    context),
              MainSearchVNLoadedState(data: var data)
                  when data.vnDictQuery.isNotEmpty || vnDictQuery.isNotEmpty =>
                searchResultTileWithVnFinished,
              MainSearchFailureState() => const SizedBox.shrink(),
              _ => searchResultTileOldWaiting,
            };
          });
        });
  }

  SearchResultTile _getSearchResultTileOldWaiting(
      int index, BuildContext context) {
    return SearchResultTile(
      loadingDefinition: true,
      hanViet: KanjiHelper.getHanvietReading(
          word: vnDictQuery[index].word, context: context),
      vnDefinition: vnDictQuery[index],
      // ignore: missing_return
    );
  }

  SearchResultTile _getSearchResultTileWithVnFinished(
      int index, BuildContext context) {
    return SearchResultTile(
      loadingDefinition: false,
      hanViet: KanjiHelper.getHanvietReading(
          word: vnDictQuery[index].word, context: context),
      vnDefinition: vnDictQuery[index],
      // ignore: missing_return
    );
  }

  SearchResultTile _getSearchResultTileVnEnFinished(
      JishoDefinition? jishoDefinition,
      int index,
      BuildContext context) {
    return SearchResultTile(
      loadingDefinition: false,
      jishoDefinition: jishoDefinition,
      hanViet: KanjiHelper.getHanvietReading(
          word: vnDictQuery[index].word, context: context),
      vnDefinition: vnDictQuery[index],
    );
  }
}

class ListSearchResultEN extends StatelessWidget
    with GetVietnameseDefinitionMixin {
  const ListSearchResultEN({
    required this.jishoDefinitionList,
    super.key,
  });

  final List<JishoDefinition> jishoDefinitionList;

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
                    hanViet: KanjiHelper.getHanvietReading(
                        word: jishoDefinitionList[index].japaneseWord,
                        context: context),
                    vnDefinition: vnSnapshot.data,
                  );
                } else
                  return SearchResultTile(
                    jishoDefinition: jishoDefinitionList[index],
                    hanViet: KanjiHelper.getHanvietReading(
                        word: jishoDefinitionList[index].japaneseWord,
                        context: context),
                  );
              });
        });
  }
}
