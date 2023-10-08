part of 'main_search_bloc.dart';

class MainSearchStateData {
  final List<VietnameseDefinition> vnDictQuery;
  final List<JishoDefinition> jishoDefinitionList;
  final bool isAppInVietnamese;
  const MainSearchStateData({
    this.vnDictQuery = const [],
    this.jishoDefinitionList = const [],
    this.isAppInVietnamese = false,
  });

  MainSearchStateData copyWith({
    List<VietnameseDefinition>? vnDictQuery,
    List<JishoDefinition>? jishoDefinitionList,
    bool? isAppInVietnamese,
  }) {
    return MainSearchStateData(
      vnDictQuery: vnDictQuery ?? this.vnDictQuery,
      jishoDefinitionList: jishoDefinitionList ?? this.jishoDefinitionList,
      isAppInVietnamese: isAppInVietnamese ?? this.isAppInVietnamese,
    );
  }

  @override
  bool operator ==(covariant MainSearchStateData other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
  
    return 
      listEquals(other.vnDictQuery, vnDictQuery) &&
      listEquals(other.jishoDefinitionList, jishoDefinitionList) &&
      other.isAppInVietnamese == isAppInVietnamese;
  }

  @override
  int get hashCode => vnDictQuery.hashCode ^ jishoDefinitionList.hashCode ^ isAppInVietnamese.hashCode;
}

sealed class MainSearchState extends Equatable {
  final MainSearchStateData data;
  
  const MainSearchState(this.data);

  @override
  List<Object> get props => [data];
}

final class MainSeachLoadingState extends MainSearchState {
  MainSeachLoadingState(super.data);
}

final class MainSearchLoadedState extends MainSearchState {
  MainSearchLoadedState(super.data);
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
