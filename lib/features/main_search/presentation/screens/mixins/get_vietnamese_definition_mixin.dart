import '../../../../../models/vietnameseDefinition.dart';
import '../../../../../services/kanjiHelper.dart';

mixin GetVietnameseDefinitionMixin {
  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word);
    return vnDefinition[0];
  }
}