import '../models/exampleSentence.dart';
import '../models/pitchAccent.dart';
import '../models/vietnameseDefinition.dart';
import '../models/kanji.dart';
import '../services/dbManager.dart';
import 'package:flutter/services.dart';

class LoadDictionary {
  final DbManager dbManager;
  LoadDictionary({required this.dbManager});

  Future<List<ExampleSentence>> loadExampleDictionary() async {
    List<ExampleSentence> exampleDictionary = [];
    try {
      String contents = await rootBundle.loadString('assets/sentence_dict.tsv');
      List<String> lines = contents.split("\n");
      lines.forEach((line) async {
        List<String?> infoByLine = line.split("\t");
        ExampleSentence exampleSentence = new ExampleSentence(
          jpSentenceId: infoByLine[0] != null ? infoByLine[0] : null,
          jpSentence: infoByLine[1] != null ? infoByLine[1] : null,
          targetSentenceId: infoByLine[2] != null ? infoByLine[2] : null,
          targetSentence: infoByLine[3] != null ? infoByLine[3] : null,
        );
        exampleDictionary.add(exampleSentence);
      });
      try {
        await dbManager.batchInsertExampleDictionary(exampleDictionary);
      } catch (e) {
        print("Error converting sentence dictionary to sqlite $e");
      }
    } catch (e) {}

    return exampleDictionary;
  }

  Future<List<Kanji>> loadAssetKanji() async {
    List<Kanji> kanjiDictionary = [];
    // kanjiDictionary = await dbManager.retrieveKanjiDictionary();
    if (kanjiDictionary.length < 1) {
      try {
        String contents = await rootBundle.loadString('assets/kanji.txt');
        List<String> lines = contents.split("\n");
        lines.forEach((line) async {
          List<String?> infoByLine = line.split("\t");
          Kanji kanji = new Kanji(
            id: infoByLine[0] != null ? infoByLine[0] : null,
            keyword: infoByLine[1] != null ? infoByLine[1] : null,
            hanViet: infoByLine[2] != null ? infoByLine[2] : null,
            kanji: infoByLine[3] != null ? infoByLine[3] : null,
            constituent: infoByLine[4] != null ? infoByLine[4] : null,
            strokeCount: infoByLine[5] != null ? infoByLine[5] : null,
            lessonNo: infoByLine[6] != null ? infoByLine[6] : null,
            heisigStory: infoByLine[7] != null ? infoByLine[7] : null,
            heisigComment: infoByLine[8] != null ? infoByLine[8] : null,
            koohiiStory1: infoByLine[9] != null ? infoByLine[9] : null,
            koohiiStory2: infoByLine[10] != null ? infoByLine[10] : null,
            jouYou: infoByLine[11] != null ? infoByLine[11] : null,
            jlpt: infoByLine[12] != null ? infoByLine[12] : null,
            onYomi: infoByLine[13] != null ? infoByLine[13] : null,
            kunYomi: infoByLine[14] != null ? infoByLine[14] : null,
            readingExamples: infoByLine[15] != null ? infoByLine[15] : null,
          );
          kanjiDictionary.add(kanji);
        });
        if (kanjiDictionary.isNotEmpty)
          try {
            await dbManager.batchInsertKanjiDictionary(kanjiDictionary);
          } catch (e) {
            print("Error converting kanji dictionary to sqlite, $e");
          }
        return kanjiDictionary;
      } catch (e) {
        // If encountering an error, return 0.
        print(e);
        return kanjiDictionary;
      }
    } else
      return kanjiDictionary;
  }

  // Load stardict dictionary from text file
  Future<List<VietnameseDefinition>> loadJpvnDictionary() async {
    List<VietnameseDefinition> dictAll = [];
    try {
      String contents = await rootBundle.loadString('assets/star_nhatviet.txt');
      List<String> lines = contents.split("\n");
      lines.forEach((line) async {
        List<String> infoByLine = line.split("\t");
        VietnameseDefinition definition = VietnameseDefinition(
            word: infoByLine[0], definition: infoByLine[1]);
        dictAll.add(definition);
      });
      if (dictAll.isNotEmpty)
        try {
          await dbManager.batchInsertJpvnDictionary(dictAll);
        } catch (e) {
          print('Error while converting to jpvnOffline sqlite $e');
        }
    } catch (e) {
      // If encountering an error, return 0.
      print('Error loading Vietnamese dictionary $e');
    }
    print(dictAll.length);
    return dictAll;
  }

  Future<void> loadPitchAccentDictionary() async {
    String cleanOrth(String orth) {
      orth = orth
        ..replaceAll("(", "")
        ..replaceAll(")", "")
        ..replaceAll("△", "")
        ..replaceAll("×", "")
        ..replaceAll("･", "")
        ..replaceAll("〈", "")
        ..replaceAll("〉", "")
        ..replaceAll("{", "")
        ..replaceAll("}", "")
        ..replaceAll("…", "〜");
      return orth;
    }

    List<PitchAccent> pitchDictionary = [];
    pitchDictionary = await dbManager.retrievePitchDictionary();
    if (pitchDictionary.length < 1) {
      int i = 0;
      try {
        String contents =
            await rootBundle.loadString('assets/wadoku_pitchdb.csv');
        List<String> lines = contents.split("\n");
        lines.forEach((line) async {
          List<String> infoByLine = line.split('\u241e');
          List<String> orthTxts = infoByLine[0].split('\u241f');
          if (cleanOrth(orthTxts[0]) != orthTxts[0]) {
            orthTxts = [cleanOrth(orthTxts[0])] + orthTxts;
          }
          List<String> patts = infoByLine[4].split(',');

          PitchAccent pitchAccent = PitchAccent(
              orthsTxt: orthTxts.toString(),
              hira: infoByLine[1],
              hz: infoByLine[2],
              accsTxt: infoByLine[3],
              pattsTxt: patts[0]);
          pitchDictionary.add(pitchAccent);
          i++;
        });
        if (pitchDictionary.isNotEmpty)
          try {
            await dbManager.batchInsertPitchDictionary(pitchDictionary);
          } catch (e) {
            print('Error while converting to pitchDictionary sqlite $e');
          }
      } catch (e) {
        print('Error loading pitch accent dictionary at line $i $e');
      }
    }
  }
}
