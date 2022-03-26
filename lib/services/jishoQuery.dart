import '../models/jishoDefinition.dart';

import 'networking.dart';

class JishoQuery {
  // Get Jisho JSON definition of words searched
  Future<dynamic> getJishoQuery(String keyword) async {
    NetworkHelper networkHelper =
        NetworkHelper('https://jisho.org/api/v1/search/words?keyword=$keyword');
    var jishoQuery = await networkHelper.getData();
    return jishoQuery;
  }

  // Transfer above JSON data to local variable
  Future<List<JishoDefinition>> getSearchResult(dynamic jishoData) async {
    List<JishoDefinition> jishoDefinitionList = [];
    for (int i = 0; i < jishoData['data'].length; i++) {
      try {
        JishoDefinition jishoDefinition = JishoDefinition(
            slug: jishoData['data'][i]['slug'],
            isCommon: jishoData['data'][i]['is_common'] == null
                ? false
                : jishoData['data'][i]['is_common'],
            tags: jishoData['data'][i]['tags'],
            jlpt: jishoData['data'][i]['jlpt'],
            word: jishoData['data'][i]['japanese'][0]['word'],
            reading: jishoData['data'][i]['japanese'][0]['reading'],
            senses: jishoData['data'][i]['senses'],
            isJmdict: jishoData['data'][i]['attribution']['jmdict'],
            isDbpedia: jishoData['data'][i]['attribution']['dbpedia'],
            isJmnedict: jishoData['data'][i]['attribution']['jmnedict']);
        jishoDefinitionList.add(jishoDefinition);
      } catch (e) {
        print('error search result list:  $e');
        print(e);
      }
    }
    print('Search result list length is ${jishoDefinitionList.length}');
    return jishoDefinitionList;
  }
}
