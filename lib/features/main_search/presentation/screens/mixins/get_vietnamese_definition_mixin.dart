import '../../../../../models/vietnamese_definition.dart';
import '../../../../../services/kanji_helper.dart';

mixin GetVietnameseDefinitionMixin {
  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word);
    return vnDefinition[0];
  }
}