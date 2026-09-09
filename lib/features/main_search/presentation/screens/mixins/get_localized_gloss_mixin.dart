import '../../../../../models/localized_gloss.dart';
import '../../../../../services/kanji_helper.dart';

mixin GetLocalizedGlossMixin {
  Future<LocalizedGloss> getLocalizedGloss(String word) async {
    List<LocalizedGloss> glossList =
        await KanjiHelper.getLocalizedGloss(word: word);
    return glossList[0];
  }
}