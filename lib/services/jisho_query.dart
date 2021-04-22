import 'networking.dart';

class JishoQuery {
  Future<dynamic> getJishoQuery(String keyword) async {
    NetworkHelper networkHelper =
        NetworkHelper('https://jisho.org/api/v1/search/words?keyword=$keyword');
    var jishoQuery = await networkHelper.getData();
    return jishoQuery;
  }
}
