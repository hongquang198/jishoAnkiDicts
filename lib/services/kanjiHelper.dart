import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/pitchAccent.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/models/dictionary.dart';

class KanjiHelper {
  // Extract kanji from word
  static Future<List<Kanji>> getKanjiComponent(
      {String word, BuildContext context}) async {
    List<Kanji> kanjiExtracted = [];
    List<Kanji> kanjiFound = [];
    for (int i = 0; i < word.length; i++) {
      try {
        kanjiFound = await Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .searchForKanji(kanji: word[i]);
        Kanji kanji =
            kanjiFound.firstWhere((element) => element.kanji == word[i]);
        if (kanji != null) {
          kanjiExtracted.add(kanji);
        }
      } catch (e) {
        print('Error extracting kanji $e');
      }
    }
    return kanjiExtracted;
  }

  static Future<List<String>> getHanvietReading(
      {String word, BuildContext context}) async {
    List<String> hanViet = [];
    List<String> array = [];
    List<Kanji> kanjiComponent =
        await getKanjiComponent(word: word, context: context);
    print('kanji component length is ${kanjiComponent.length}');
    for (int i = 0; i < kanjiComponent.length; i++) {
      try {
        array = kanjiComponent[i].hanViet.split(" ");
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
      {String character, int position, String pitchAccent}) {
    if (pitchAccent[position] == 'L' || pitchAccent[position] == 'l') {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
            right: pitchAccent[position + 1] == 'H' ||
                    pitchAccent[position + 1] == 'h'
                ? BorderSide(
                    color: Colors.black,
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
              color: Colors.black,
              width: 1.0,
            ),
            right: pitchAccent[position + 1] == 'L' ||
                    pitchAccent[position + 1] == 'l'
                ? BorderSide(
                    color: Colors.black,
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
    String word,
    String slug,
    String reading,
    BuildContext context,
  }) async {
    List<Widget> widgetList = [];
    List<PitchAccent> pitchFound =
        await Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .searchForPitchAccent(word: slug ?? word, reading: reading);
    String pitchAccent;
    PitchAccent pitch;
    try {
      pitch = pitchFound.firstWhere((element) =>
          element.orths_txt.contains(word ?? slug ?? reading) &&
          element.hira == reading);
    } catch (e) {
      print(e);
      return null;
    }
    pitchAccent = pitch.patts_txt;
    if (reading.length + 1 == pitchAccent.length)
      for (int i = 0; i < reading.length; i++)
        widgetList.add(getPitchForChar(
            character: reading[i], position: i, pitchAccent: pitchAccent));
    return widgetList;
  }

  static Future<String> getVnDefinition(
      {String word, BuildContext context}) async {
    List<VietnameseDefinition> vietnameseDefinition;
    try {
      vietnameseDefinition =
          await Provider.of<Dictionary>(context, listen: false)
              .offlineDatabase
              .searchForVnMeaning(word: word);
    } catch (e) {
      print('Error searching for vn definition $e');
    }
    if (vietnameseDefinition.length > 0)
      return vietnameseDefinition[0].definition;
    return null;
  }

  static Future<List<ExampleSentence>> getExampleSentence(
      {String word, BuildContext context}) async {
    List<ExampleSentence> exampleSentence;
    try {
      exampleSentence = await Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .searchForExample(word: word);
    } catch (e) {
      print('Error searching for example $e');
    }
    return exampleSentence;
  }
}