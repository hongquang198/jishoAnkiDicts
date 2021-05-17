import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/material.dart';

class ExampleSentenceWidget extends StatefulWidget {
  final String word;
  final String slug;
  ExampleSentenceWidget({this.word, this.slug});
  @override
  _ExampleSentenceWidgetState createState() => _ExampleSentenceWidgetState();
}

class _ExampleSentenceWidgetState extends State<ExampleSentenceWidget> {
  Future<List<ExampleSentence>> exampleSentence;

  @override
  void initState() {
    try {
      if (SharedPref.prefs.getString('language').contains('English'))
        exampleSentence = KanjiHelper.getExampleSentence(
            word: widget.word,
            context: context,
            tableName: 'englishExampleDictionary');
      else if (SharedPref.prefs.getString('language') == 'Tiếng Việt') {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: widget.word,
            context: context,
            tableName: 'exampleDictionary');
      }
    } catch (e) {
      print('Error getting example sentence $e');
    }
    super.initState();
  }

  List<Widget> generateSentence(List<ExampleSentence> exampleSentence) {
    List<Widget> sentence = [];
    for (int i = 0; i < exampleSentence.length; i++) {
      if (i == 5) break;
      sentence.add(Text(
        exampleSentence[i].jpSentence,
        style: TextStyle(
            fontSize: Constants.definitionTextSize,
            fontWeight: FontWeight.bold),
      ));
      sentence.add(Text(
        exampleSentence[i].targetSentence,
        style: TextStyle(fontSize: Constants.definitionTextSize),
      ));
    }
    return sentence;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: exampleSentence,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            print('Example dictionary is null');
            return SizedBox();
          }
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: generateSentence(snapshot.data));
        });
  }
}

// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: <Widget>[
// Text(
// '${snapshot.data[0].jpSentence}',
// style: TextStyle(
// fontSize: Constants.definitionTextSize,
// fontWeight: FontWeight.bold),
// ),
// Text(
// '${snapshot.data[0].vnSentence}',
// style: TextStyle(fontSize: Constants.definitionTextSize),
// ),
// Text(
// '${snapshot.data[1].jpSentence}',
// style: TextStyle(
// fontSize: Constants.definitionTextSize,
// fontWeight: FontWeight.bold),
// ),
// Text(
// '${snapshot.data[1].vnSentence}',
// style: TextStyle(fontSize: Constants.definitionTextSize),
// ),
// ],
// );
