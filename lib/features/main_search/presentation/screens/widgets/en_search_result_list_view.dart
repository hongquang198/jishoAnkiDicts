import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/main_search_bloc.dart';
import '../mixins/get_vietnamese_definition_mixin.dart';
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
        return ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  thickness: 0.4,
                ),
            itemCount: stateData.jishoDefinitionList.length,
            itemBuilder: (BuildContext context, int index) {
              return SearchResultTileEn(
                jishoDefinition: stateData.jishoDefinitionList[index],
              );
            });
      },
    );
  }
}
