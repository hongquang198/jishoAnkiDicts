import '../../../injection.dart';
import '../../../models/example_sentence.dart';
import '../../../models/pitch_accent.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/db_manager.dart';
import '../../data/datasources/shared_pref.dart';
import '../../../models/grammar_point.dart';
import '../../../models/kanji.dart';
import '../../../models/offline_word_record.dart';

class Dictionary {
  late List<VietnameseDefinition> vietnameseDictionary;
  late List<Kanji> kanjiDictionary;
  late List<ExampleSentence> exampleDictionary;
  late List<OfflineWordRecord> history;
  late List<OfflineWordRecord> favorite;
  late List<OfflineWordRecord> review;
  late List<PitchAccent> pitchAccentDict;
  late List<GrammarPoint> grammarDict;
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
    List<int> newCardsStep = getIt<SharedPref>().prefs
        .getStringList('newCardsSteps')
        ?.map((e) => int.parse(e))
        .toList() ?? [];

    review.forEach((element) {
      if (element.reviews != 0) {
        if (element.interval <=
            newCardsStep[newCardsStep.length - 1] * 60 * 1000)
          numberOfLearnedCards++;
      }
    });
    return numberOfLearnedCards;
  }

  int get getYoungCardNumber {
    int numberOfYoungCards = 0;

    review.forEach((element) {
      if (element.reviews != 0) {
        if (element.interval <= 21 * 24 * 60 * 60 * 1000 &&
            element.due < DateTime.now().millisecondsSinceEpoch)
          numberOfYoungCards++;
      }
    });
    return numberOfYoungCards;
  }

  int get getDueCardNumber {
    int numberOfDueCards = 0;
    List<int> newCardsStep = getIt<SharedPref>().prefs
        .getStringList('newCardsSteps')
        ?.map((e) => int.parse(e))
        .toList() ?? [];
    review.forEach((element) {
      print(
          element.interval - newCardsStep[newCardsStep.length - 1] * 60 * 1000);
      if (element.interval >
              newCardsStep[newCardsStep.length - 1] * 60 * 1000 &&
          element.due < DateTime.now().millisecondsSinceEpoch)
        numberOfDueCards++;
    });
    return numberOfDueCards;
  }

  int get getMatureCardNumber {
    int numberOfMatureCards = 0;
    review.forEach((element) {
      if (element.interval > 21 * 24 * 60 * 60 * 1000 &&
          element.due < DateTime.now().millisecondsSinceEpoch)
        numberOfMatureCards++;
    });
    return numberOfMatureCards;
  }

  int get getDifficultCardNumber {
    int lapses = 0;
    review.forEach((element) {
      if (element.lapses > 5) lapses++;
    });
    return lapses;
  }

  List<OfflineWordRecord> get getCards {
    List<int> newCardsStep = getIt<SharedPref>().prefs
        .getStringList('newCardsSteps')
        ?.map((e) => int.parse(e))
        .toList() ?? [];
    List<OfflineWordRecord> dueCards = [];
    List<OfflineWordRecord> newCards = [];
    int dueNumber = 0;
    review.forEach((element) {
      if (element.reviews == 0) {
        // print('new ${element.word}');
        newCards.add(element);
      } else if (element.due < DateTime.now().millisecondsSinceEpoch) {
        // print('due<datenow ${element.word}');
        dueCards.add(element);
        dueNumber++;
      } else if (element.due - DateTime.now().millisecondsSinceEpoch <=
          newCardsStep[newCardsStep.length - 1] * 60 * 1000) {
        dueCards.add(element);
        // print('due-date<steps ${element.word}');
      }
    });

    dueCards.sort((a, b) => a.due.compareTo(b.due));
    // Add new cards to the end of due cards
    newCards.forEach((element) {
      dueCards.add(element);
    });

    if (dueNumber == 0) {
      dueCards.forEach((element) {
        newCards.add(element);
      });
      return newCards;
    }
    return dueCards;
  }
}
