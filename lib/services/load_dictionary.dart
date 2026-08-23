import 'dart:developer';
import 'package:flutter/services.dart';

import '../models/example_sentence.dart';
import '../models/pitch_accent.dart';
import '../models/vietnamese_definition.dart';
import '../models/kanji.dart';
import 'db_manager.dart';

class LoadDictionary {
  final DbManager dbManager;
  LoadDictionary({required this.dbManager});

  Future<List<ExampleSentence>> loadExampleDictionary() async {
    List<ExampleSentence> exampleDictionary = [];
    try {
      String contents = await rootBundle.loadString('assets/sentence_dict.tsv');
      List<String> lines = contents.split('\n');
      for (final line in lines) {
        List<String?> infoByLine = line.split('\t');
        ExampleSentence exampleSentence = ExampleSentence(
          jpSentenceId: infoByLine[0],
          jpSentence: infoByLine[1],
          targetSentenceId: infoByLine[2],
          targetSentence: infoByLine[3],
        );
        exampleDictionary.add(exampleSentence);
      }
      try {
        await dbManager.batchInsertExampleDictionary(exampleDictionary);
      } catch (e) {
        log('Error converting sentence dictionary to sqlite $e');
      }
    } catch (e) {
      log('Error loading sentence dictionary: $e');
    }

    return exampleDictionary;
  }

  Future<List<Kanji>> loadAssetKanji() async {
    List<Kanji> kanjiDictionary = [];
    // kanjiDictionary = await dbManager.retrieveKanjiDictionary();
    if (kanjiDictionary.isEmpty) {
      try {
        String contents = await rootBundle.loadString('assets/kanji.txt');
        List<String> lines = contents.split('\n');
        for (final line in lines) {
          List<String?> infoByLine = line.split('\t');
          Kanji kanji = Kanji(
            id: infoByLine[0],
            keyword: infoByLine[1],
            hanViet: infoByLine[2],
            kanji: infoByLine[3],
            constituent: infoByLine[4],
            strokeCount: infoByLine[5],
            lessonNo: infoByLine[6],
            heisigStory: infoByLine[7],
            heisigComment: infoByLine[8],
            koohiiStory1: infoByLine[9],
            koohiiStory2: infoByLine[10],
            jouYou: infoByLine[11],
            jlpt: infoByLine[12],
            onYomi: infoByLine[13],
            kunYomi: infoByLine[14],
            readingExamples: infoByLine[15],
          );
          kanjiDictionary.add(kanji);
        }
        if (kanjiDictionary.isNotEmpty) {
          try {
            await dbManager.batchInsertKanjiDictionary(kanjiDictionary);
          } catch (e) {
            log('Error converting kanji dictionary to sqlite, $e');
          }
        }
        return kanjiDictionary;
      } catch (e) {
        // If encountering an error, return empty list.
        log('$e');
        return kanjiDictionary;
      }
    } else {
      return kanjiDictionary;
    }
  }

  // Load stardict dictionary from text file
  Future<List<VietnameseDefinition>> loadJpvnDictionary() async {
    List<VietnameseDefinition> dictAll = [];
    try {
      String contents = await rootBundle.loadString('assets/star_nhatviet.txt');
      List<String> lines = contents.split('\n');
      for (final line in lines) {
        List<String> infoByLine = line.split('\t');
        VietnameseDefinition definition = VietnameseDefinition(
            word: infoByLine[0], definition: infoByLine[1]);
        dictAll.add(definition);
      }
      if (dictAll.isNotEmpty) {
        try {
          await dbManager.batchInsertJpvnDictionary(dictAll);
        } catch (e) {
          log('Error while converting to jpvnOffline sqlite $e');
        }
      }
    } catch (e) {
      // If encountering an error, return empty list.
      log('Error loading Vietnamese dictionary $e');
    }
    log('${dictAll.length}');
    return dictAll;
  }

  Future<void> loadPitchAccentDictionary() async {
    String cleanOrth(String orth) {
      orth = orth
        ..replaceAll('(', '')
        ..replaceAll(')', '')
        ..replaceAll('△', '')
        ..replaceAll('×', '')
        ..replaceAll('･', '')
        ..replaceAll('〈', '')
        ..replaceAll('〉', '')
        ..replaceAll('{', '')
        ..replaceAll('}', '')
        ..replaceAll('…', '〜');
      return orth;
    }

    List<PitchAccent> pitchDictionary = [];
    pitchDictionary = await dbManager.retrievePitchDictionary();
    if (pitchDictionary.isEmpty) {
      int i = 0;
      try {
        String contents =
            await rootBundle.loadString('assets/wadoku_pitchdb.csv');
        List<String> lines = contents.split('\n');
        for (final line in lines) {
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
        }
        if (pitchDictionary.isNotEmpty) {
          try {
            await dbManager.batchInsertPitchDictionary(pitchDictionary);
          } catch (e) {
            log('Error while converting to pitchDictionary sqlite $e');
          }
        }
      } catch (e) {
        log('Error loading pitch accent dictionary at line $i $e');
      }
    }
  }
}
