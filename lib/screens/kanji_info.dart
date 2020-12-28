import 'package:JapaneseOCR/models/kanji.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';

// Future<List<String>> getFileLines() async {
//   final data = await rootBundle.load('assets/kanji.txt');
//   final directory = (await getTemporaryDirectory()).path;
//   final file = await writeToFile(data, '$directory/kanji.txt');
//   return await file.readAsLines();
// }
//
// Future<File> writeToFile(ByteData data, String path) {
//   return File(path).writeAsBytes(data.buffer.asUint8List(
//     data.offsetInBytes,
//     data.lengthInBytes,
//   ));
// }

Future<List<Kanji>> loadAsset() async {
  try {
    String contents = await rootBundle.loadString('assets/kanji.txt');
    List<String> lines = contents.split("\n");
    List<Kanji> kanjiAll = [];
    int i = 0;
    lines.forEach((line) {
      List<String> infoByLine = line.split("\t");
      Kanji kanji = new Kanji(
        id: infoByLine[0] != null ? int.parse(infoByLine[0]) : null,
        keyword: infoByLine[1] != null ? infoByLine[1] : null,
        hanViet: infoByLine[2] != null ? infoByLine[2] : null,
        kanji: infoByLine[3] != null ? infoByLine[3] : null,
        constituent: infoByLine[4] != null ? infoByLine[4] : null,
        strokeCount: infoByLine[5] != null ? int.parse(infoByLine[5]) : null,
        lessonNo: infoByLine[6] != null ? int.parse(infoByLine[6]) : null,
        heisigStory: infoByLine[7] != null ? infoByLine[7] : null,
        heisigComment: infoByLine[8] != null ? infoByLine[8] : null,
        koohiiStory1: infoByLine[9] != null ? infoByLine[9] : null,
        koohiiStory2: infoByLine[10] != null ? infoByLine[10] : null,
        jouYou: infoByLine[11] != null ? int.parse(infoByLine[11]) : null,
        jlpt: infoByLine[12] != null ? int.parse(infoByLine[12]) : null,
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
    print(i);
    print(kanjiAll.length);
    return kanjiAll;
  } catch (e) {
    // If encountering an error, return 0.
    print(e);
  }
}

class KanjiInfo extends StatefulWidget {
  @override
  _KanjiInfoState createState() => _KanjiInfoState();
}

class _KanjiInfoState extends State<KanjiInfo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Kanji>>(
      future: loadAsset(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(snapshot.data[0].kanji)),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
