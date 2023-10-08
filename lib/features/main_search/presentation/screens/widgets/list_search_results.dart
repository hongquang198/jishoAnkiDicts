import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';

import '../../../../../models/vietnameseDefinition.dart';
import '../../../../../services/kanjiHelper.dart';
import '../../../../../widgets/main_screen/search_result_tile.dart';
import '../../../domain/entities/jisho_definition.dart';
import '../mixins/get_vietnamese_definition_mixin.dart';

class ListSearchResultVN extends StatelessWidget {
  const ListSearchResultVN({
    super.key,
    required this.vnDictQuery,
    required this.textEditingController,
  });

  final List<VietnameseDefinition> vnDictQuery;
  final TextEditingController textEditingController;

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
                MainSeachLoadingState() => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                MainSearchLoadedState(data: var data) when data.jishoDefinitionList.any((element) => element.japaneseWord == vnDictQuery[index].word)
                        => _getSearchResultTileVnEnFinished(
                          data.jishoDefinitionList.firstWhere((element) => element.japaneseWord == vnDictQuery[index].word), index, context),
                MainSearchLoadedState(data: var data) when data.vnDictQuery.isNotEmpty || vnDictQuery.isNotEmpty 
                    => searchResultTileWithVnFinished,
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
      jishoDefinition: JishoDefinition(
        slug: '',
        isCommon: false,
        tags: [],
        jlpt: [],
        word: 'waiting',
        reading: '',
        senses: jsonDecode(
            '[{"english_definitions":[],"parts_of_speech":[],"links":[],"tags":[],"restrictions":[],"see_also":[],"antonyms":[],"source":[],"info":[]}]'),
        isJmnedict: '',
        isDbpedia: '',
        isJmdict: '',
      ),
      textEditingController: textEditingController,
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
      jishoDefinition: JishoDefinition(
        slug: '',
        isCommon: false,
        tags: [],
        jlpt: [],
        word: 'waiting',
        reading: '',
        senses: jsonDecode(
            '[{"english_definitions":[],"parts_of_speech":[],"links":[],"tags":[],"restrictions":[],"see_also":[],"antonyms":[],"source":[],"info":[]}]'),
        isJmnedict: '',
        isDbpedia: '',
        isJmdict: '',
      ),
      textEditingController: textEditingController,
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
      textEditingController: textEditingController,
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
    required this.textEditingController,
    super.key,
  });

  final List<JishoDefinition> jishoDefinitionList;
  final TextEditingController textEditingController;

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
                    textEditingController: textEditingController,
                    hanViet: KanjiHelper.getHanvietReading(
                        word: jishoDefinitionList[index].japaneseWord,
                        context: context),
                    vnDefinition: vnSnapshot.data,
                  );
                } else
                  return SearchResultTile(
                    jishoDefinition: jishoDefinitionList[index],
                    textEditingController: textEditingController,
                    hanViet: KanjiHelper.getHanvietReading(
                        word: jishoDefinitionList[index].japaneseWord,
                        context: context),
                  );
              });
        });
  }
}
