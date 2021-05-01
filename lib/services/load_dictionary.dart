import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/pitchAccent.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/services/dbManager.dart';

class LoadDictionary {
  final DbManager dbManager;
  LoadDictionary({this.dbManager});

  Future<List<ExampleSentence>> loadExampleDictionary() async {
    List<ExampleSentence> exampleDictionary = [];
    int i = 0;

    try {
      String contents = await rootBundle.loadString('assets/sentence_dict.tsv');
      List<String> lines = contents.split("\n");
      lines.forEach((line) async {
        List<String> infoByLine = line.split("\t");
        ExampleSentence exampleSentence = new ExampleSentence(
          jpSentenceId: infoByLine[0] != null ? infoByLine[0] : null,
          jpSentence: infoByLine[1] != null ? infoByLine[1] : null,
          vnSentenceId: infoByLine[2] != null ? infoByLine[2] : null,
          vnSentence: infoByLine[3] != null ? infoByLine[3] : null,
        );
        exampleDictionary.add(exampleSentence);

        // if (exampleSentence != null)
        //   try {
        //     await dbManager.insertExampleDictionary(exampleSentence);
        //   } catch (e) {
        //     print("Error converting sentence dictionary to sqlite $e");
        //   }
        i++;
      });
    } catch (e) {}

    return exampleDictionary;
  }

  Future<List<Kanji>> loadAssetKanji() async {
    List<Kanji> kanjiDictionary = [];
    try {
      String contents = await rootBundle.loadString('assets/kanji.txt');
      List<String> lines = contents.split("\n");
      int i = 0;
      lines.forEach((line) async {
        List<String> infoByLine = line.split("\t");
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

        // if (kanji != null)
        //   try {
        //     await dbManager.insertKanjiDictionary(kanji);
        //   } catch (e) {
        //     print("Error converting kanji dictionary to sqlite, $e");
        //   }
        i++;
      });
    } catch (e) {
      // If encountering an error, return 0.
      print(e);
    }
    return kanjiDictionary;
  }

  // Load stardict dictionary from text file
  Future<List<VietnameseDefinition>> loadAssetDictionary() async {
    List<VietnameseDefinition> dictAll = [];
    try {
      String contents = await rootBundle.loadString('assets/star_nhatviet.txt');
      List<String> lines = contents.split("\n");
      lines.forEach((line) async {
        List<String> infoByLine = line.split("\t");
        VietnameseDefinition definition = VietnameseDefinition(
            word: infoByLine[0] ?? '', definition: infoByLine[1]);
        dictAll.add(definition);
        // if (definition != null)
        //   try {
        //     await dbManager.insertJpvnDictionary(definition);
        //   } catch (e) {
        //     print('Error while converting to jpvnOffline sqlite $e');
        //   }
      });
    } catch (e) {
      // If encountering an error, return 0.
      print('Error loading Vietnamese dictionary $e');
    }
    print(dictAll.length);
    return dictAll;
  }

  Future<List<PitchAccent>> loadPitchAccentDictionary() async {
    // TODO: Shorten this to one single line of code
    String clean_orth(String orth) {
      orth = orth.replaceAll("(", "");
      orth = orth.replaceAll(")", "");
      orth = orth.replaceAll("△", "");
      orth = orth.replaceAll("×", "");
      orth = orth.replaceAll("･", "");
      orth = orth.replaceAll("〈", "");
      orth = orth.replaceAll("〉", "");
      orth = orth.replaceAll("{", "");
      orth = orth.replaceAll("}", "");
      orth = orth.replaceAll("…", "〜");
      return orth;
    }

    List<PitchAccent> acc_dict = [];
    int i = 0;
    try {
      String contents =
          await rootBundle.loadString('assets/wadoku_pitchdb.csv');
      List<String> lines = contents.split("\n");
      lines.forEach((line) {
        List<String> infoByLine = line.split('\u241e');
        List<String> orth_txts = infoByLine[0].split('\u241f');
        if (clean_orth(orth_txts[0]) != orth_txts[0]) {
          orth_txts = [clean_orth(orth_txts[0])] + orth_txts;
        }
        List<String> patts = infoByLine[4].split(',');

        PitchAccent pitchAccent = PitchAccent(
            orths_txt: orth_txts,
            hira: infoByLine[1],
            hz: infoByLine[2],
            accs_txt: infoByLine[3],
            patts_txt: patts[0]);
        acc_dict.add(pitchAccent);
        i++;
      });
      return acc_dict;
    } catch (e) {
      print('Error loading pitch accent dictionary at line $i $e');
    }
  }
}
