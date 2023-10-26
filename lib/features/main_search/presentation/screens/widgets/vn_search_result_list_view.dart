import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';

import '../../../../single_grammar_point/screen/widgets/grammar_query_tile.dart';
import 'search_result_tile_vn.dart';

class VnSearchResultListView extends StatelessWidget {
  const VnSearchResultListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchBloc, MainSearchState>(
        builder: (context, state) {
      final stateData = state.data;
      return SingleChildScrollView(
        child: Column(children: [
          ...stateData.grammarPointList
              .map((e) => Column(
                children: [
                  GrammarQueryTile(
                        grammarPoint: e,
                        showGrammarBadge: true,
                      ),
                  divider,
                ],
              ))
              .toList(),
          ...stateData.vnDictQuery.mapIndexed(
            (index, vnDefinition) => Column(
              children: [
                SearchResultTileVn(
                  vnDefinition: vnDefinition,
                  hanViet: _getHanViet(stateData, vnDefinition.word),
                  jishoDefinition: stateData.jishoDefinitionList.firstWhereOrNull(
                      (element) => element.japaneseWord == vnDefinition.word),
                ),
                divider,
              ],
            ),
          ),
          ...stateData.jishoDefinitionList
              .mapIndexed((index, jishoDefintiion) => Column(
                children: [
                  SearchResultTileVn(
                        hanViet: _getHanViet(stateData, jishoDefintiion.japaneseWord),
                        jishoDefinition: jishoDefintiion,
                      ),
                  divider,
                ],
              ))
              .toList(),
        ]),
      );
    });
  }

  Divider get divider => Divider(thickness: 0.4);

  List<String> _getHanViet(MainSearchStateData stateData, String word) {
    return stateData.wordToHanVietMap[word] ?? [];
  }
}
