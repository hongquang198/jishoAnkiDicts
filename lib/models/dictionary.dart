import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'kanji.dart';

class Dictionary {
  List<VietnameseDefinition> vietnameseDictionary;
  List<Kanji> kanjiDictionary;
  List<ExampleSentence> exampleDictionary;
  List<OfflineWordRecord> history;
  List<OfflineWordRecord> favorite;

  // This database is used to store history/favorite list from users
  DbManager offlineDatabase = DbManager(dbName: 'offlineDatabase');
}
