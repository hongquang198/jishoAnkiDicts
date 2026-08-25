import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/injection.dart';

mixin GetWordViewCountMixin {
  Future<int> getViewCounts({required String currentJapaneseWord}) async {
    return getIt<UserDataRepository>().getWordViewCount(currentJapaneseWord);
  }
}
