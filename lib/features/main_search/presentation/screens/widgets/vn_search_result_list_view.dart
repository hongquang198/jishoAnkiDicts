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

class _VnSearchResultListViewState extends State<VnSearchResultListView> with RouteAware {
  List<Widget> searchResults = [];
  Divider get divider => Divider(thickness: 0.4);

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }


  @override
  void didPopNext() {
    context.read<MainSearchBloc>().add(TriggerAnimationEvent());
    super.didPopNext();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchBloc, MainSearchState>(
        builder: (context, state) {
      final stateData = state.data;
      final grammarPointList = stateData.grammarPointList;
      final vnDictQuery = stateData.vnDictQuery;
      final jishoDefinitionList = stateData.jishoDefinitionList;
      searchResults.clear();
      searchResults.addAll([
          ...grammarPointList
              .mapIndexed((index, e) => 
                  GrammarQueryTile(
                    animationDuration:  Duration(
                    milliseconds:
                        (index + 1 % 10) * 300),
                        grammarPoint: e,
                        showGrammarBadge: true,
                      ),
              )
              .toList(),
          ...vnDictQuery.mapIndexed(
            (index, vnDefinition) =>
                SearchResultTileVn(
                animationDuration: Duration(
                    milliseconds:
                        ((grammarPointList.length + index + 1) % 10) * 300),
                  vnDefinition: vnDefinition,
                  hanViet: _getHanViet(stateData, vnDefinition.word),
                  jishoDefinition: stateData.jishoDefinitionList.firstWhereOrNull(
                      (element) => element.japaneseWord == vnDefinition.word),
            ),
          ),
          ...jishoDefinitionList
              .mapIndexed((index, jishoDefintiion) =>
                  SearchResultTileVn(
                    animationDuration: Duration(
                        milliseconds: ((grammarPointList.length +
                                vnDictQuery.length +
                                index + 1) % 10) *
                            300),
                    hanViet:
                        _getHanViet(stateData, jishoDefintiion.japaneseWord),
                    jishoDefinition: jishoDefintiion,
                  ))
          .toList(),
        ]);
      return SingleChildScrollView(
        child: Column(children: searchResults),
      );
    });
  }
  List<String> _getHanViet(MainSearchStateData stateData, String word) {
    return stateData.wordToHanVietMap[word] ?? [];
  }
}
