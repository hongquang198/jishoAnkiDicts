import 'package:unofficial_jisho_api/api.dart';

abstract class JishoRemoteDataSource {
  Future<JishoAPIResult> searchForPhrase({required String phrase});
}

class JishoRemoteDataSourceImpl extends JishoRemoteDataSource {
  @override
  Future<JishoAPIResult> searchForPhrase({required String phrase}) async {
    return await searchForPhrase(phrase: phrase);
  }
}
