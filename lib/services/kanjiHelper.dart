import 'package:collection/collection.dart';

import '../models/exampleSentence.dart';
import '../models/kanji.dart';
import '../models/pitchAccent.dart';
import '../models/vietnameseDefinition.dart';
import '../utils/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dictionary.dart';

class KanjiHelper {
  // Extract kanji from word
  static Future<List<Kanji>> getKanjiComponent(
      {required String word, required BuildContext context}) async {
    List<Kanji> kanjiExtracted = [];
    List<Kanji> kanjiFound = [];
    for (int i = 0; i < word.length; i++) {
      try {
        kanjiFound = await Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .searchForKanji(kanji: word[i]);
        Kanji? kanji =
            kanjiFound.firstWhereOrNull((element) => element.kanji == word[i]);
        if (kanji != null) {
          kanjiExtracted.add(kanji);
        }
      } catch (e) {
        // print('Error extracting kanji $e');
      }
    }
    return kanjiExtracted;
  }

  static Future<List<String>> getHanvietReading(
      {required String word, required BuildContext context}) async {
    List<String> hanViet = [];
    List<String> array = [];
    List<Kanji> kanjiComponent =
        await getKanjiComponent(word: word, context: context);
    // print('kanji component length is ${kanjiComponent.length}');
    for (int i = 0; i < kanjiComponent.length; i++) {
      try {
        array = kanjiComponent[i].hanViet?.split(" ") ?? [];
        array = array[0].split(",");
        hanViet.add(array[0].toUpperCase());
      } catch (e) {
        print('error adding kanji extracted $e');
      }
    }
    return hanViet;
  }

  // Draw a box with border corresponding to its pitch
  // For example, if the pitch is low, bottom border will be drawn, side border is dependent on the next character pitch
  static Container getPitchForChar(
      {required String character, required int position, required String pitchAccent}) {
    if (pitchAccent[position] == 'L' || pitchAccent[position] == 'l') {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: SharedPref.prefs.getString('theme') == 'dark'
                  ? Colors.white
                  : Colors.black,
              width: 1.0,
            ),
            right: pitchAccent[position + 1] == 'H' ||
                    pitchAccent[position + 1] == 'h'
                ? BorderSide(
                    color: SharedPref.prefs.getString('theme') == 'dark'
                        ? Colors.white
                        : Colors.black,
                    width: 1.0,
                  )
                : BorderSide(
                    color: Colors.transparent,
                    width: 0.0,
                  ),
          ),
        ),
        child: Text(
          character,
        ),
      );
    } else
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: SharedPref.prefs.getString('theme') == 'dark'
                  ? Colors.white
                  : Colors.black,
              width: 1.0,
            ),
            right: pitchAccent[position + 1] == 'L' ||
                    pitchAccent[position + 1] == 'l'
                ? BorderSide(
                    color: SharedPref.prefs.getString('theme') == 'dark'
                        ? Colors.white
                        : Colors.black,
                    width: 1.0,
                  )
                : BorderSide(
                    color: Colors.transparent,
                    width: 0.0,
                  ),
          ),
        ),
        child: Text(
          character,
        ),
      );
  }

  static Future<List<Widget>> getPitchAccent({
    String? word,
    String? slug,
    String? reading,
    required BuildContext context,
  }) async {
    List<Widget> widgetList = [];
    List<PitchAccent> pitchFound =
        await Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .searchForPitchAccent(word: slug ?? word ?? '', reading: reading ?? '');
    String pitchAccent;
    PitchAccent pitch;
    try {
      pitch = pitchFound.firstWhere((element) =>
          element.orthsTxt.contains(word ?? slug ?? reading ?? '') &&
          element.hira == reading);
    } catch (e) {
      print(e);
      return [];
    }
    pitchAccent = pitch.pattsTxt;
    if ((reading?.length ?? 0) + 1 == pitchAccent.length)
      for (int i = 0; i < (reading?.length ?? 0); i++)
        widgetList.add(getPitchForChar(
            character: reading?[i] ?? '', position: i, pitchAccent: pitchAccent));
    return widgetList;
  }

  static Future<List<VietnameseDefinition>> getVnDefinition(
      {required String word, required BuildContext context}) async {
    late List<VietnameseDefinition> vietnameseDefinition;
    try {
      vietnameseDefinition =
          await Provider.of<Dictionary>(context, listen: false)
              .offlineDatabase
              .searchForVnMeaning(word: word);
    } catch (e) {
      print('Error searching for vn definition $e');
    }
    return vietnameseDefinition;
  }

  static Future<List<ExampleSentence>> getExampleSentence(
      {required String word, required BuildContext context, required String tableName}) async {
    late List<ExampleSentence> exampleSentence;
    try {
      exampleSentence = await Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .searchForExample(word: word, tableName: tableName);
    } catch (e) {
      print('Error searching for example $e');
    }
    return exampleSentence;
  }
}
