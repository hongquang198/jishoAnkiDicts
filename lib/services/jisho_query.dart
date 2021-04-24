import 'package:JapaneseOCR/models/jishoDefinition.dart';

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
    var data = jishoData['data'];
    for (int i = 0; i < 10; i++) {
      try {
        JishoDefinition jishoDefinition = JishoDefinition(
            slug: jishoData['data'][i]['slug'],
            is_common: jishoData['data'][i]['is_common'] == null
                ? false
                : jishoData['data'][i]['is_common'],
            tags: jishoData['data'][i]['tags'],
            jlpt: jishoData['data'][i]['jlpt'],
            word: jishoData['data'][i]['japanese'][0]['word'],
            reading: jishoData['data'][i]['japanese'][0]['reading'],
            senses: jishoData['data'][i]['senses'],
            is_jmdict: jishoData['data'][i]['attribution']['jmdict'],
            is_dbpedia: jishoData['data'][i]['attribution']['dbpedia'],
            is_jmnedict: jishoData['data'][i]['attribution']['jmnedict']);
        jishoDefinitionList.add(jishoDefinition);
      } catch (e) {
        print('error: ');
        print(e);
      }
    }
    print(jishoDefinitionList.length);
    return jishoDefinitionList;
  }
}
