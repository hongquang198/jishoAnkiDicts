import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/example_sentence.dart';
import '../../../models/grammar_point.dart';
import '../../../models/kanji.dart';
import '../../../services/kanji_helper.dart';
import '../../../utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../word_definition/screens/widgets/component_widget.dart';
import '../../word_definition/screens/widgets/example_sentence_widget.dart';

class GrammarPointScreen extends StatefulWidget {
  final GrammarPoint grammarPoint;
  GrammarPointScreen({required this.grammarPoint});

  @override
  _GrammarPointScreenState createState() => _GrammarPointScreenState();
}

class _GrammarPointScreenState extends State<GrammarPointScreen> {
  late Future<List<Kanji>> kanjiList;

  Widget getPartsOfSpeech(List<dynamic> partsOfSpeech) {
    if (partsOfSpeech.length > 0) {
        return Text(
          partsOfSpeech.first.toString().toUpperCase(),
        );
    }
    return SizedBox();
  }

  Future<List<ExampleSentence>> getGrammarExamples() async {
    List<ExampleSentence> query =
        await getIt<Dictionary>()
            .offlineDatabase
            .searchForGrammarExample(
                grammarPoint: widget.grammarPoint.grammarPoint!);
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
        word: widget.grammarPoint.grammarPoint!, context: context);
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
                  widget.grammarPoint.grammarPoint!,
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
                  widget.grammarPoint.jlptLevel!,
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
              widget.grammarPoint.grammarMeaning!,
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
