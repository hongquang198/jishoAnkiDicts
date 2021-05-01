import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/pitchAccent.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'kanji.dart';
import 'offlineWordRecord.dart';

class Dictionary {
  List<VietnameseDefinition> vietnameseDictionary;
  List<Kanji> kanjiDictionary;
  List<ExampleSentence> exampleDictionary;
  List<OfflineWordRecord> history;
  List<OfflineWordRecord> favorite;
  List<OfflineWordRecord> review;
  List<PitchAccent> pitchAccentDict;
  // This database is used to store history/favorite list from users
  DbManager offlineDatabase = DbManager(dbName: 'offlineDatabase');

  int get getNewCardNumber {
    int numberOfNewCards = 0;
    review.forEach((element) {
      if (element.reviews == 0) numberOfNewCards++;
    });
    return numberOfNewCards;
  }

  int get getLearnedCardNumber {
    int numberOfLearnedCards = 0;
    review.forEach((element) {
      if (element.reviews != 0) if (element.interval / 1000 / 60 <= 10) {
        numberOfLearnedCards++;
      }
    });
    return numberOfLearnedCards;
  }

  int get getDueCardNumber {
    int numberOfDueCards = 0;
    review.forEach((element) {
      if (element.interval / 1000 / 60 > 10 &&
          element.due - DateTime.now().millisecondsSinceEpoch <
              24 * 60 * 60 * 1000) numberOfDueCards++;
    });
    return numberOfDueCards;
  }
}
