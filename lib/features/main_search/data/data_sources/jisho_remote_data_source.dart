import 'package:unofficial_jisho_api/api.dart';

abstract class JishoRemoteDataSource {
  Future<JishoAPIResult> searchJishoForPhrase({required String phrase});
}

class JishoRemoteDataSourceImpl extends JishoRemoteDataSource {
  @override
  Future<JishoAPIResult> searchJishoForPhrase({required String phrase}) async {
    return await searchForPhrase(phrase);
  }
}
