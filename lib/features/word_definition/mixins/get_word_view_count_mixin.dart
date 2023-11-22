import 'package:collection/collection.dart';

import '../../../core/domain/entities/dictionary.dart';
import '../../../injection.dart';
import '../../../models/offline_word_record.dart';

mixin GetWordViewCountMixin {
  int getViewCounts({required String currentJapaneseWord}) {
    OfflineWordRecord? found;
    try {
      found = getIt<Dictionary>().history.firstWhereOrNull((element) {
        String elementWord = element.word;
        if (elementWord.isEmpty) {
          elementWord = element.slug;
        }
        return elementWord == currentJapaneseWord;
      });
    } catch (e) {
      print('Word not in history: $e');
    }
    if (found == null)
      return 0;
    else
      return found.reviews;
  }

}