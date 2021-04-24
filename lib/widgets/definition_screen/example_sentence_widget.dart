import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExampleSentenceWidget extends StatefulWidget {
  String word;
  String slug;
  ExampleSentenceWidget({this.word, this.slug});
  @override
  _ExampleSentenceWidgetState createState() => _ExampleSentenceWidgetState();
}

class _ExampleSentenceWidgetState extends State<ExampleSentenceWidget> {
  List<ExampleSentence> exampleSentence;

  @override
  Widget build(BuildContext context) {
    List<ExampleSentence> exampleSentence = [];
    try {
      exampleSentence.add(Provider.of<Dictionary>(context)
          .exampleDictionary
          .firstWhere((element) =>
              element.jpSentence.contains(widget.slug ?? widget.word)));
      exampleSentence.add(Provider.of<Dictionary>(context)
          .exampleDictionary
          .lastWhere((element) =>
              element.jpSentence.contains(widget.slug ?? widget.word)));
    } catch (e) {
      print('Error getting example sentence $e');
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${exampleSentence[0].jpSentence}',
          style: TextStyle(
              fontSize: Constants.definitionTextSize,
              fontWeight: FontWeight.bold),
        ),
        Text(
          '${exampleSentence[0].vnSentence}',
          style: TextStyle(fontSize: Constants.definitionTextSize),
        ),
        Text(
          '${exampleSentence[1].jpSentence}',
          style: TextStyle(
              fontSize: Constants.definitionTextSize,
              fontWeight: FontWeight.bold),
        ),
        Text(
          '${exampleSentence[1].vnSentence}',
          style: TextStyle(fontSize: Constants.definitionTextSize),
        ),
      ],
    );
  }
}
