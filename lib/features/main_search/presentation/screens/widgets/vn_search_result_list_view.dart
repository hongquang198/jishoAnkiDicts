import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jisho_anki/features/main_search/presentation/bloc/main_search_bloc.dart';

import '../../../../../config/app_routes.dart';
import '../../../../../services/db_helper.dart';
import '../../../../../utils/offline_list_type.dart';
import '../../../../single_grammar_point/screen/widgets/grammar_query_tile.dart';
import '../../../../word_definition/screens/definition_screen.dart';
import 'search_result_tile_vn.dart';

part 'vn_search_result_list_view.children.dart';

class VnSearchResultListView extends StatefulWidget {
  const VnSearchResultListView({
    super.key,
  });

  @override
  State<VnSearchResultListView> createState() => _VnSearchResultListViewState();
}

class _VnSearchResultListViewState extends State<VnSearchResultListView> {
  List<Widget> searchResults = [];
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchBloc, MainSearchState>(
        builder: (context, state) {
      final stateData = state.data;
      searchResults.clear();
      searchResults.addAll([
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
        ]);
      return SingleChildScrollView(
        child: Column(children: searchResults),
      );
    });
  }

  Divider get divider => Divider(thickness: 0.4);

  List<String> _getHanViet(MainSearchStateData stateData, String word) {
    return stateData.wordToHanVietMap[word] ?? [];
  }
}
