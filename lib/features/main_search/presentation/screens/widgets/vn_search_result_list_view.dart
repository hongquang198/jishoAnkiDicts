import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';

import 'search_result_tile.dart';

class VnSearchResultListView extends StatelessWidget {
  const VnSearchResultListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchBloc, MainSearchState>(
        builder: (context, state) {
      final stateData = state.data;
      if (stateData.vnDictQuery.isNotEmpty) {
        return ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  thickness: 0.4,
                ),
            itemCount: state.data.vnDictQuery.length,
            itemBuilder: (BuildContext context, int index) {
              return SearchResultTile(
                vnDefinition: stateData.vnDictQuery[index],
                hanViet: _getHanViet(stateData, index),
                jishoDefinition: stateData.jishoDefinitionList.firstWhereOrNull(
                    (element) =>
                        element.japaneseWord ==
                        stateData.vnDictQuery[index].word),
              );
            });
      }
      return ListView.separated(
          separatorBuilder: (context, index) => Divider(
                thickness: 0.4,
              ),
          itemCount: state.data.jishoDefinitionList.length,
          itemBuilder: (BuildContext context, int index) {
            return SearchResultTile(
              hanViet: _getHanViet(stateData, index),
              jishoDefinition: stateData.jishoDefinitionList[index],
            );
          });
    });
  }

  List<String> _getHanViet(MainSearchStateData stateData, int index) {
    if (stateData.vnDictQuery.isNotEmpty) {
      return stateData.wordToHanVietMap[stateData.vnDictQuery[index].word] ??
          [];
    }
    return stateData.wordToHanVietMap[
            stateData.jishoDefinitionList[index].japaneseWord] ??
        [];
  }
}