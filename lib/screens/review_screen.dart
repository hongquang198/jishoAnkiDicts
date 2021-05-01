import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:JapaneseOCR/services/dbHelper.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:JapaneseOCR/widgets/definition_screen/component_widget.dart';
import 'package:JapaneseOCR/widgets/definition_screen/definition_tags.dart';
import 'package:JapaneseOCR/widgets/definition_screen/example_sentence_widget.dart';
import 'package:JapaneseOCR/widgets/review_screen/answerButton.dart';
import 'package:JapaneseOCR/widgets/review_screen/reviewInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/widgets/definition_screen/definition_widget.dart';
import 'dart:async';

import 'cardInfoScreen.dart';

class ReviewScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  ReviewScreen({this.textEditingController});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int currentCard = 0;
  String clipboard;
  bool showAll = false;
  List<int> steps;

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

  Future<String> getClipboard() async {
    ClipboardData data = await Clipboard.getData('text/plain');
    clipboard = data.text;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getClipboard();
    steps = SharedPref.prefs
        .getStringList('newCardsSteps')
        .map((i) => int.parse(i))
        .toList();
    widget.textEditingController.addListener(() {
      if (mounted) {
        if (clipboard != widget.textEditingController.text) {
          clipboard = widget.textEditingController.text;
          Navigator.of(context).popUntil((route) => route.isFirst);
          print('Definition screen popped');
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Review'),
          actions: [
            Icon(Icons.undo),
            Icon(Icons.brush),
            Icon(Icons.menu),
            GestureDetector(
                onTap: () {
                  setState(() {
                    DbHelper.removeFromOfflineList(
                        offlineListType: OfflineListType.review,
                        context: context,
                        senses:
                            jsonDecode(dictionary.review[currentCard].senses),
                        slug: dictionary.review[currentCard].slug,
                        word: dictionary.review[currentCard].word);
                  });
                },
                child: Icon(Icons.delete)),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CardInfoScreen(
                                offlineWordRecord:
                                    dictionary.review[currentCard],
                              )));
                },
                child: Icon(Icons.info))
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(24),
            child: Container(
              height: 24,
              color: Color(0xFFF7E7E6),
              child: ReviewInfo(),
            ),
          ),
        ),
        body: currentCard < dictionary.review.length
            ? buildCard(dictionary, context)
            : Center(
                child: Text('You completed your reviews'),
              ),
      );
    });
  }

  Column buildCard(Dictionary dictionary, BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          showAll == true &&
                  KanjiHelper.getPitchAccent(
                          word: dictionary.review[currentCard].word ?? '',
                          slug: dictionary.review[currentCard].slug ?? '',
                          reading: dictionary.review[currentCard].reading ?? '',
                          pitchAccentDict: dictionary.pitchAccentDict) !=
                      null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: KanjiHelper.getPitchAccent(
                      word: dictionary.review[currentCard].word ?? '',
                      slug: dictionary.review[currentCard].slug ?? '',
                      reading: dictionary.review[currentCard].reading ?? '',
                      pitchAccentDict: dictionary.pitchAccentDict),
                )
              : SizedBox(),
          Center(
            child: Text(
              dictionary.review[currentCard].word ??
                  dictionary.review[currentCard].slug ??
                  dictionary.review[currentCard].reading ??
                  '',
              style: TextStyle(
                fontSize: 45.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          showAll == true
              ? Center(
                  child: Text(
                    KanjiHelper.getHanvietReading(
                            word: dictionary.review[currentCard].word,
                            kanjiDict: dictionary.kanjiDictionary)
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                )
              : SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              dictionary.review[currentCard].is_common == 1
                  ? Card(
                      color: Color(0xFF8ABC82),
                      child: Text(
                        'common word',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(),
              DefinitionTags(
                  tags: jsonDecode(dictionary.review[currentCard].tags),
                  color: Color(0xFF909DC0)),
              DefinitionTags(
                  tags: jsonDecode(dictionary.review[currentCard].jlpt),
                  color: Color(0xFF909DC0)),
            ],
          ),
          SizedBox(height: 8),
          showAll == true
              ? Center(
                  child: DefinitionWidget(
                    senses: jsonDecode(dictionary.review[currentCard].senses),
                    vietnameseDefinition:
                        dictionary.review[currentCard].vietnamese_definition,
                  ),
                )
              : SizedBox(),
          Divider(),
          showAll == true
              ? Center(
                  child: Text(
                    'Examples',
                    style: TextStyle(
                      color: Color(0xffDB8C8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                )
              : SizedBox(),
          showAll == true
              ? Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: ExampleSentenceWidget(
                      word: dictionary.review[currentCard].slug ??
                          dictionary.review[currentCard].word),
                )
              : SizedBox(),
          Divider(),
          showAll == true
              ? Center(
                  child: Text(
                    'Components',
                    style: TextStyle(
                      color: Color(0xffDB8C8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                )
              : SizedBox(),
          showAll == true
              ? Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: ComponentWidget(
                    kanjiList: KanjiHelper.extractKanji(
                        word: dictionary.review[currentCard].word,
                        kanjiDict: dictionary.kanjiDictionary),
                  ),
                )
              : SizedBox(),
        ]),
      ),
      TextField(
        decoration: InputDecoration(hintText: 'Enter your answer'),
      ),
      SizedBox(height: 5),
      if (showAll == false)
        GestureDetector(
          onTap: () {
            setState(() {
              showAll = true;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Color(0xFF385499),
            child: Center(
              child: Text(
                'Show answer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      else
        Container(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    dictionary.review[currentCard].ease =
                        SharedPref.prefs.getDouble('startingEase');
                    showAll = false;
                    if (dictionary.review[currentCard].reviews == 0) {
                      dictionary.review[currentCard].firstReview =
                          DateTime.now().millisecondsSinceEpoch;
                    } else {
                      // If card is mature
                      if (dictionary.review[currentCard].interval >
                          21 * 24 * 60 * 60 * 1000) {
                        dictionary.review[currentCard].lapses++;
                      }
                    }
                    dictionary.review[currentCard].lastReview =
                        DateTime.now().millisecondsSinceEpoch;
                    dictionary.review[currentCard].interval =
                        steps[0] * 60 * 1000;
                    dictionary.review[currentCard].due =
                        DateTime.now().millisecondsSinceEpoch +
                            dictionary.review[currentCard].interval;
                    dictionary.review[currentCard].reviews++;
                    DbHelper.updateWordInfo(
                        offlineListType: OfflineListType.review,
                        context: context,
                        senses:
                            jsonDecode(dictionary.review[currentCard].senses),
                        offlineWordRecord: dictionary.review[currentCard]);
                    currentCard++;
                  });
                },
                child: AnswerButton(
                    currentCard: currentCard,
                    steps: steps,
                    buttonText: 'Again',
                    color: Colors.red),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAll = false;
                    dictionary.review[currentCard].lastReview =
                        DateTime.now().millisecondsSinceEpoch;
                    if (dictionary.review[currentCard].reviews == 0)
                      dictionary.review[currentCard].firstReview =
                          DateTime.now().millisecondsSinceEpoch;
                    if (dictionary.review[currentCard].interval <
                        steps[steps.length - 1] * 60 * 1000)
                      for (int i = 0; i < steps.length; i++) {
                        if (dictionary.review[currentCard].interval <
                            steps[i] * 60 * 1000) {
                          dictionary.review[currentCard].interval =
                              steps[i] * 60 * 1000;
                          break;
                        }
                      }
                    else if (dictionary.review[currentCard].interval ==
                        steps[steps.length - 1] * 60 * 1000) {
                      dictionary.review[currentCard].interval =
                          SharedPref.prefs.getInt('graduatingInterval') *
                              24 *
                              60 *
                              60 *
                              1000;
                    } else if (dictionary.review[currentCard].interval >=
                        SharedPref.prefs.getInt('graduatingInterval') *
                            24 *
                            60 *
                            60 *
                            1000) {
                      dictionary.review[currentCard].interval =
                          (dictionary.review[currentCard].interval *
                                  dictionary.review[currentCard].ease)
                              .round();
                    }
                    dictionary.review[currentCard].due =
                        dictionary.review[currentCard].interval +
                            DateTime.now().millisecondsSinceEpoch;

                    dictionary.review[currentCard].reviews++;
                    DbHelper.updateWordInfo(
                        offlineListType: OfflineListType.review,
                        context: context,
                        senses:
                            jsonDecode(dictionary.review[currentCard].senses),
                        offlineWordRecord: dictionary.review[currentCard]);
                    currentCard++;
                  });
                },
                child: AnswerButton(
                    currentCard: currentCard,
                    steps: steps,
                    buttonText: 'Good',
                    color: Colors.green),
              )
            ],
          ),
        ),
    ]);
  }
}
