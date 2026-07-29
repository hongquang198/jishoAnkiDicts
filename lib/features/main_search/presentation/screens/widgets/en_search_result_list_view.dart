import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/main_search_bloc.dart';
import '../mixins/get_vietnamese_definition_mixin.dart';
import 'llm_search_result_tile.dart';
import 'search_result_tile_en.dart';

class EnSearchResultListView extends StatelessWidget
    with GetVietnameseDefinitionMixin {
  const EnSearchResultListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchBloc, MainSearchState>(
      builder: (context, state) {
        final stateData = state.data;
        final hasPhrase = stateData.searchedPhrase.trim().isNotEmpty;
        final jishoList = stateData.jishoDefinitionList;

        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            thickness: 0.4,
          ),
          itemCount: (hasPhrase ? 1 : 0) + jishoList.length,
          itemBuilder: (BuildContext context, int index) {
            if (hasPhrase && index == 0) {
              return LlmSearchResultTile(query: stateData.searchedPhrase.trim());
            }
            final jishoIndex = hasPhrase ? index - 1 : index;
            return SearchResultTileEn(
              jishoDefinition: jishoList[jishoIndex],
            );
          },
        );
      },
    );
  }
}
