
import 'package:JapaneseOCR/models/definition.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:flutter/services.dart';

class LoadDictionary {
  Future<List<Kanji>> loadAssetKanji() async {
    List<Kanji> kanjiAll = [];

    try {
      String contents = await rootBundle.loadString('assets/kanji.txt');
      List<String> lines = contents.split("\n");
      int i = 0;
      lines.forEach((line) {
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
        try {
          kanjiAll.add(kanji);
        } catch (e) {
          print("number error is $i");
          print(e);
        }
        i++;
      });
    } catch (e) {
      // If encountering an error, return 0.
      print(e);
    }
    return kanjiAll;
  }

  // Load stardict dictionary from text file
  Future<List<Definition>> loadAssetDictionary() async {
    List<Definition> dictAll = [];

    try {
      String contents = await rootBundle.loadString('assets/star_nhatviet.txt');
      List<String> lines = contents.split("\n");
      lines.forEach((line) {
        List<String> infoByLine = line.split("\t");
        Definition definition = new Definition(
            word: infoByLine[0] != null ? infoByLine[0] : null,
            definition: infoByLine[2]
        );

        try {
          dictAll.add(definition);
        } catch (e) {
          print(e);
        }
      });


    } catch (e) {
      // If encountering an error, return 0.
      print(e);
    }
    return dictAll;
  }

}