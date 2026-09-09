import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../injection.dart';
import '../models/example_sentence.dart';
import '../models/kanji.dart';
import '../models/pitch_accent.dart';
import '../models/localized_gloss.dart';
import '../core/data/datasources/shared_pref.dart';
import '../core/domain/entities/dictionary.dart';

class KanjiHelper {
  // Extract kanji from word
  static Future<List<Kanji>> getKanjiComponent({required String word}) async {
    List<Kanji> kanjiExtracted = [];
    List<Kanji> kanjiFound = [];
    for (int i = 0; i < word.length; i++) {
      try {
        kanjiFound = await getIt<Dictionary>()
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

  static Future<List<String>> getHanvietReading({required String word}) async {
    List<String> hanViet = [];
    List<String> array = [];
    List<Kanji> kanjiComponent = await getKanjiComponent(word: word);
    // print('kanji component length is ${kanjiComponent.length}');
    for (int i = 0; i < kanjiComponent.length; i++) {
      try {
        array = kanjiComponent[i].hanViet?.split(' ') ?? [];
        array = array[0].split(',');
        hanViet.add(array[0].toUpperCase());
      } catch (e) {
        log('error adding kanji extracted $e');
      }
    }
    return hanViet;
  }

  // Draw a box with border corresponding to its pitch
  // For example, if the pitch is low, bottom border will be drawn, side border is dependent on the next character pitch
  static Container getPitchForChar(
      {required String character,
      required int position,
      required String pitchAccent}) {
    if (pitchAccent[position] == 'L' || pitchAccent[position] == 'l') {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: getIt<SharedPref>().prefs.getString('theme') == 'dark'
                  ? Colors.white
                  : Colors.black,
              width: 1.0,
            ),
            right: pitchAccent[position + 1] == 'H' ||
                    pitchAccent[position + 1] == 'h'
                ? BorderSide(
                    color:
                        getIt<SharedPref>().prefs.getString('theme') == 'dark'
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
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: getIt<SharedPref>().prefs.getString('theme') == 'dark'
                  ? Colors.white
                  : Colors.black,
              width: 1.0,
            ),
            right: pitchAccent[position + 1] == 'L' ||
                    pitchAccent[position + 1] == 'l'
                ? BorderSide(
                    color:
                        getIt<SharedPref>().prefs.getString('theme') == 'dark'
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
  }

  /// Builds pitch accent boxes from a raw L/H pattern (e.g. "LHHH") and its
  /// reading. The pattern must be exactly one character longer than the
  /// reading, mirroring [getPitchAccent]'s database format.
  static List<Widget> buildPitchWidgets({
    required String reading,
    required String pitchPattern,
  }) {
    final widgetList = <Widget>[];
    if (reading.isEmpty) return widgetList;
    if (reading.length + 1 != pitchPattern.length) return widgetList;
    for (int i = 0; i < reading.length; i++) {
      widgetList.add(getPitchForChar(
          character: reading[i], position: i, pitchAccent: pitchPattern));
    }
    return widgetList;
  }

  /// Exact orthography match against the stored `orthsTxt` list string
  /// (e.g. `"[救済, 救濟]"`). Substring `contains` would match longer
  /// compounds like `農尊救済` for a `救済` lookup, producing a wrong reading
  /// such as のうそんきゅうさい — so exact token equality is required.
  static bool _isExactOrthMatch(String orthsTxt, String lookupWord) {
    final stripped = orthsTxt.trim();
    final inner = stripped.startsWith('[') && stripped.endsWith(']')
        ? stripped.substring(1, stripped.length - 1)
        : stripped;
    for (final token in inner.split(',')) {
      if (token.trim() == lookupWord) return true;
    }
    return false;
  }

  static Future<List<Widget>> getPitchAccent({
    String? word,
    String? slug,
    String? reading,

    /// Unused today; kept optional so callers may pass it without crossing
    /// async-gap lints.
    BuildContext? context,
  }) async {
    List<Widget> widgetList = [];
    // Prefer the first non-empty orth key: VN-DB words arrive with an empty
    // jisho slug/word stub, so `slug ?? word` alone would query ''.
    String lookupWord = '';
    if (word?.isNotEmpty == true) {
      lookupWord = word!;
    } else if (slug?.isNotEmpty == true) {
      lookupWord = slug!;
    } else if (reading?.isNotEmpty == true) {
      lookupWord = reading!;
    }
    if (lookupWord.isEmpty) return [];
    final lookupReading = reading ?? '';
    List<PitchAccent> pitchFound = await getIt<Dictionary>()
        .offlineDatabase
        .searchForPitchAccent(word: lookupWord, reading: lookupReading);
    String pitchAccent;
    PitchAccent pitch;
    try {
      if (lookupReading.isNotEmpty) {
        // Exact orth + exact reading first.
        pitch = pitchFound.firstWhere((element) =>
            _isExactOrthMatch(element.orthsTxt, lookupWord) &&
            element.hira == lookupReading);
      } else {
        // VN-DB path (no reading): exact orth only. Never fall back to
        // substring matching — showing nothing beats showing a longer
        // compound's pitch (e.g. のうそんきゅうさい for 救済).
        pitch = pitchFound.firstWhere(
            (element) => _isExactOrthMatch(element.orthsTxt, lookupWord));
      }
    } catch (e) {
      log('$e');
      return [];
    }
    // VN-DB words carry no jisho reading: render the DB hira so the accent
    // boxes still have characters to annotate.
    final displayReading =
        lookupReading.isNotEmpty ? lookupReading : pitch.hira;
    pitchAccent = pitch.pattsTxt;
    if (displayReading.length + 1 == pitchAccent.length) {
      for (int i = 0; i < displayReading.length; i++) {
        widgetList.add(getPitchForChar(
            character: displayReading[i],
            position: i,
            pitchAccent: pitchAccent));
      }
    }
    return widgetList;
  }

  static Future<List<LocalizedGloss>> getLocalizedGloss(
      {required String word}) async {
    late List<LocalizedGloss> localizedGloss;
    try {
      localizedGloss = await getIt<Dictionary>()
          .offlineDatabase
          .searchForLocalizedGloss(word: word);
    } catch (e) {
      log('Error searching for localized gloss $e');
    }
    return localizedGloss;
  }

  static Future<List<ExampleSentence>> getExampleSentence(
      {required String word,

      /// Unused today; kept optional so callers may pass it without crossing
      /// async-gap lints.
      BuildContext? context,
      required String tableName}) async {
    late List<ExampleSentence> exampleSentence;
    try {
      exampleSentence = await getIt<Dictionary>()
          .offlineDatabase
          .searchForExample(word: word, tableName: tableName);
    } catch (e) {
      log('Error searching for example $e');
    }
    return exampleSentence;
  }
}
