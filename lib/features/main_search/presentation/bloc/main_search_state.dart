part of 'main_search_bloc.dart';

class MainSearchStateData {
  final List<VietnameseDefinition> vnDictQuery;
  final List<JishoDefinition> jishoDefinitionList;
  final bool isAppInVietnamese;
  final Map<String, List<String>> wordToHanVietMap;

  const MainSearchStateData({
    this.vnDictQuery = const [],
    this.jishoDefinitionList = const [],
    this.isAppInVietnamese = false,
    this.wordToHanVietMap = const {},
  });

  JishoDefinition? getSpecificJishoDefinition({required String japaneseWord}) =>
      jishoDefinitionList
          .firstWhereOrNull((element) => element.japaneseWord == japaneseWord);


  MainSearchStateData copyWith({
    List<VietnameseDefinition>? vnDictQuery,
    List<JishoDefinition>? jishoDefinitionList,
    bool? isAppInVietnamese,
    Map<String, List<String>>? wordToHanVietMap,
  }) {
    return MainSearchStateData(
      vnDictQuery: vnDictQuery ?? this.vnDictQuery,
      jishoDefinitionList: jishoDefinitionList ?? this.jishoDefinitionList,
      isAppInVietnamese: isAppInVietnamese ?? this.isAppInVietnamese,
      wordToHanVietMap: wordToHanVietMap ?? this.wordToHanVietMap,
    );
  }

  @override
  bool operator ==(covariant MainSearchStateData other) {
    if (identical(this, other)) return true;
  
    return 
      listEquals(other.vnDictQuery, vnDictQuery) &&
      listEquals(other.jishoDefinitionList, jishoDefinitionList) &&
      other.isAppInVietnamese == isAppInVietnamese &&
      mapEquals(other.wordToHanVietMap, wordToHanVietMap);
  }

  @override
  int get hashCode {
    return vnDictQuery.hashCode ^
      jishoDefinitionList.hashCode ^
      isAppInVietnamese.hashCode ^
      wordToHanVietMap.hashCode;
  }
}

sealed class MainSearchState extends Equatable {
  final MainSearchStateData data;
  
  const MainSearchState(this.data);

  @override
  List<Object> get props => [data];
}

final class MainSearchLoadingState extends MainSearchState {
  MainSearchLoadingState(super.data);
}

final class MainSearchVNLoadedState extends MainSearchState {
  MainSearchVNLoadedState(super.data);
}

final class MainSearchAllLoadedState extends MainSearchState {
  MainSearchAllLoadedState(super.data);
}

final class MainSearchFailureState extends MainSearchState {
  final String failureMessage;
  MainSearchFailureState(super.data, {
    required this.failureMessage,
  });

  @override
  List<Object> get props => [
        failureMessage,
        super.props,
      ];
}
