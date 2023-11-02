part of 'vn_search_result_list_view.dart';

extension _VnSearchResultListViewStateExt on _VnSearchResultListViewState {
  void _handleKeyEvent(RawKeyEvent event) {
    final logicalKey = event.logicalKey;
    final keyLabel = logicalKey.keyLabel;
    if (event is RawKeyDownEvent) {
      return;
    }
    if (keyLabel.isEmpty || !isNumericCharacter(keyLabel)) {
      return;
    }

    final searchResultChildren =
        searchResults
        .expand((e) => (e as Column).children
          ..removeWhere((element) => element is Divider))
        .toList();
    final number = int.tryParse(keyLabel)!;
    if (searchResultChildren.isEmpty || number > searchResultChildren.length) {
      return;
    }

    final searchResultChild = searchResultChildren[number-1];
    if (searchResultChild is SearchResultTileVn) {
      context.pushNamed(
        AppRoutesPath.wordDefinition,
        extra: DefinitionScreenArgs(
          mainSearchBloc: context.read<MainSearchBloc>(),
          hanViet: searchResultChild.hanViet,
          jishoDefinition: searchResultChild.jishoDefinition,
          vnDefinition: searchResultChild.vnDefinition,
          isInFavoriteList: DbHelper.checkDatabaseExist(
              offlineListType: OfflineListType.favorite,
              word: searchResultChild.vnDefinition?.word ??
                  searchResultChild.jishoDefinition?.japaneseWord ??
                  '',
              context: context),
        ),
      );
      return;
    }

    if (searchResultChild is GrammarQueryTile) {
      context.pushNamed(AppRoutesPath.singleGrammarPoint,
          extra: searchResultChild.grammarPoint);
    }
  }

  bool isNumericCharacter(String input) {
    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].contains(int.tryParse(input));
  }
}
