import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/pitchAccent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/models/dictionary.dart';

class KanjiHelper {
  // Extract kanji from word
  static List<Kanji> extractKanji({String word, List<Kanji> kanjiDict}) {
    List<Kanji> kanjiExtracted = [];
    for (int i = 0; i < word.length; i++) {
      try {
        Kanji kanji =
            kanjiDict.firstWhere((element) => element.kanji == word[i]);
        if (kanji != null) {
          kanjiExtracted.add(kanji);
        }
      } catch (e) {
        print('Error extracting kanji $e');
      }
    }
    return kanjiExtracted;
  }

  static List<String> getHanvietReading({String word, List<Kanji> kanjiDict}) {
    List<String> hanViet = [];
    List<String> array = [];
    List<Kanji> kanjiExtracted = extractKanji(word: word, kanjiDict: kanjiDict);
    for (int i = 0; i < kanjiExtracted.length; i++) {
      try {
        array = kanjiExtracted[i].hanViet.split(" ");
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

  static List<Widget> getPitchAccent(
      {String word,
      String slug,
      String reading,
      List<PitchAccent> pitchAccentDict}) {
    List<Widget> widgetList = [];
    String pitchAccent;
    PitchAccent pitch;
    try {
      pitch = pitchAccentDict.firstWhere((element) =>
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
}
