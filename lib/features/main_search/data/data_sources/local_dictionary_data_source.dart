import 'package:unofficial_jisho_api/api.dart';

abstract class LocalDictionaryDataSource {
  Future<JishoAPIResult> searchForPhrase({required String phrase});
}

class JishoRemoteDataSourceImpl extends LocalDictionaryDataSource {
  @override
  Future<JishoAPIResult> searchForPhrase({required String phrase}) async {
    return await searchForPhrase(phrase: phrase);
  }
}
