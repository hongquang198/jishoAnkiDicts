import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/exampleSentence.dart';
import 'package:JapaneseOCR/models/grammarPoint.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/widgets/definition_screen/component_widget.dart';
import 'package:JapaneseOCR/widgets/definition_screen/example_sentence_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class GrammarPointScreen extends StatefulWidget {
  final GrammarPoint grammarPoint;
  GrammarPointScreen({this.grammarPoint});

  @override
  _GrammarPointScreenState createState() => _GrammarPointScreenState();
}

class _GrammarPointScreenState extends State<GrammarPointScreen> {
  Future<List<Kanji>> kanjiList;

  Widget getPartsOfSpeech(List<dynamic> partsOfSpeech) {
    if (partsOfSpeech.length > 0) {
      for (int i = 0; i < partsOfSpeech.length; i++) {
        return Text(
          partsOfSpeech[i].toString().toUpperCase(),
        );
      }
    }
    return SizedBox();
  }

  Future<List<ExampleSentence>> getGrammarExamples() async {
    List<ExampleSentence> query =
        await Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .searchForGrammarExample(
                grammarPoint: widget.grammarPoint.grammarPoint);
    return query;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    kanjiList = KanjiHelper.getKanjiComponent(
        word: widget.grammarPoint.grammarPoint, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.grammarPoint.grammarPoint,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Card(
                color: Color(0xFF8ABC82),
                child: Text(
                  widget.grammarPoint.jlptLevel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(bottom: 10, left: 10),
            child: Text(
              widget.grammarPoint.grammarMeaning,
              style: TextStyle(fontSize: Constants.definitionTextSize),
            ),
          ),
          Divider(),
          Text(
            'Examples',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          ExampleSentenceWidget(
            exampleSentence: getGrammarExamples(),
          ),
          Divider(),
          Text(
            'Components',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          ComponentWidget(
            kanjiComponent: kanjiList,
          ),
        ]),
      ),
    );
  }
}
