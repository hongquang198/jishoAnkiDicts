import 'dart:convert';
import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/exampleSentence.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/models/vietnameseDefinition.dart';
import 'package:JapaneseOCR/utils/redoType.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:JapaneseOCR/services/dbHelper.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:JapaneseOCR/widgets/customDialog.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'cardInfoScreen.dart';

class ReviewScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  ReviewScreen({this.textEditingController});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int totalCardNumber;
  String clipboard;
  bool showAll = false;
  List<int> steps;
  Future<List<Widget>> pitchAccent;
  Future<List<Kanji>> kanjiComponent;
  Future<List<String>> hanViet;
  OfflineWordRecord redo;
  OfflineWordRecord currentCard;
  RedoType redoType;
  Future<List<ExampleSentence>> enExampleSentence;
  Future<List<ExampleSentence>> vnExampleSentence;

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

  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnList = [];
    try {
      vnList = await KanjiHelper.getVnDefinition(word: word, context: context);
      return vnList[0];
    } catch (e) {
      print('No VN definition found $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // getKanjiComponent() async {
  //   kanjiComponent = KanjiHelper.getKanjiComponent(
  //       word: Provider.of<Dictionary>(context, listen: false)
  //               .getCards[currentCard]
  //               .word ??
  //           Provider.of<Dictionary>(context, listen: false)
  //               .getCards[currentCard]
  //               .slug,
  //       context: context);
  // }
  //
  // drawPitchAccent() async {
  //   pitchAccent = KanjiHelper.getPitchAccent(
  //       word: Provider.of<Dictionary>(context, listen: false)
  //           .getCards[currentCard]
  //           .word,
  //       slug: Provider.of<Dictionary>(context, listen: false)
  //           .getCards[currentCard]
  //           .slug,
  //       reading: Provider.of<Dictionary>(context, listen: false)
  //           .getCards[currentCard]
  //           .reading,
  //       context: context);
  //   return pitchAccent;
  // }

  @override
  void initState() {
    // Get steps from settings to calculate card's next interval
    steps = SharedPref.prefs
        .getStringList('newCardsSteps')
        .map((i) => int.parse(i))
        .toList();

    // Add listener to listen to clipboard change to look up fast
    widget.textEditingController.addListener(() {
      if (mounted) {
        if (clipboard != widget.textEditingController.text) {
          clipboard = widget.textEditingController.text;
          Navigator.of(context).popUntil((route) => route.isFirst);
          print('Definition screen popped');
        }
      }
    });

    // Review list maybe empty so try catch
    try {
      currentCard = Provider.of<Dictionary>(context, listen: false).getCards[0];
      redo = currentCard;
      updateAdditionalInfo();
    } catch (e) {
      print('Card empty. $e');
    }

    getClipboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).review),
          actions: [
            GestureDetector(
                onTap: () async {
                  if (redo != null) currentCard = redo;
                  if (redoType == RedoType.update) {
                    DbHelper.updateWordInfo(
                        offlineListType: OfflineListType.review,
                        context: context,
                        senses: jsonDecode(currentCard.senses),
                        offlineWordRecord: currentCard);
                  } else if (redoType == RedoType.delete) {
                    DbHelper.addToOfflineList(
                        offlineListType: OfflineListType.review,
                        offlineWordRecord: currentCard,
                        context: context);
                  }
                  showAll = false;
                  dictionary.getCards;
                  updateAdditionalInfo();
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Icon(Icons.undo),
                )),
            GestureDetector(
                onTap: () async {
                  if (dictionary.getCards.length > 0 &&
                      dictionary.getCards.length != null) {
                    redo = OfflineWordRecord(
                      slug: currentCard.slug,
                      is_common: currentCard.is_common,
                      tags: currentCard.tags,
                      jlpt: currentCard.jlpt,
                      word: currentCard.word,
                      reading: currentCard.reading,
                      senses: currentCard.senses,
                      vietnamese_definition: currentCard.vietnamese_definition,
                      added: currentCard.added,
                      firstReview: currentCard.firstReview,
                      lastReview: currentCard.lastReview,
                      due: currentCard.due,
                      interval: currentCard.interval,
                      ease: currentCard.ease,
                      reviews: currentCard.reviews,
                      lapses: currentCard.lapses,
                      averageTimeMinute: currentCard.averageTimeMinute,
                      totalTimeMinute: currentCard.totalTimeMinute,
                      cardType: currentCard.cardType,
                      noteType: currentCard.noteType,
                      deck: currentCard.deck,
                    );

                    redoType = RedoType.delete;

                    DbHelper.removeFromOfflineList(
                        offlineListType: OfflineListType.review,
                        context: context,
                        word: currentCard.word);
                    if (dictionary.getCards.length != 0) {
                      currentCard = dictionary.getCards[0];
                      updateAdditionalInfo();
                    }
                    setState(() {
                      showAll = false;
                    });
                  } else
                    print('No card');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Icon(Icons.delete),
                )),
            GestureDetector(
                onTap: () {
                  dictionary.getCards.length > 0 &&
                          dictionary.getCards.length != null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CardInfoScreen(
                                    offlineWordRecord: currentCard,
                                  )))
                      : print('No card');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Icon(Icons.info),
                ))
          ],
          bottom: dictionary.getCards.length > 0 &&
                  dictionary.getCards.length != null
              ? PreferredSize(
                  preferredSize: Size.fromHeight(24),
                  child: Container(
                    height: 24,
                    color: Color(0xFFF7E7E6),
                    child: ReviewInfo(
                      offlineWordRecord: currentCard,
                    ),
                  ),
                )
              : PreferredSize(
                  child: SizedBox(), preferredSize: Size.fromHeight(0)),
        ),
        body: dictionary.getCards.length > 0
            ? buildCard(dictionary, context)
            : Center(
                child: Text(AppLocalizations.of(context).reviewComplete),
              ),
      );
    });
  }

  // How to decide which card is shown first ? use a list = dictionary.getCards at index 0 since every review updates cards position
  // For example, a card due in 1 minute will be updated to show earlier than a card due in 10 minutes
  // The card position update is actually in the getCards function
  Column buildCard(Dictionary dictionary, BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          showAll == true
              ? FutureBuilder(
                  future: KanjiHelper.getPitchAccent(
                      word: currentCard.word,
                      slug: currentCard.slug,
                      reading: currentCard.reading,
                      context: context),
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return Center(
                        child: Text(
                          currentCard.reading ?? '',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: snapshot.data,
                    );
                  },
                )
              : SizedBox(),
          Center(
            child: Text(
              currentCard.word ?? currentCard.slug ?? currentCard.reading ?? '',
              style: TextStyle(
                fontSize: 45.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          showAll == true &&
                  SharedPref.prefs.getString('language') == 'Tiếng Việt'
              ? FutureBuilder(
                  future: hanViet,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) return SizedBox();
                    return Center(
                      child: Text(
                        snapshot.data.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    );
                  },
                )
              : SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              currentCard.is_common == 1
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
                  tags: jsonDecode(currentCard.tags), color: Color(0xFF909DC0)),
              DefinitionTags(
                  tags: jsonDecode(currentCard.jlpt), color: Color(0xFF909DC0)),
            ],
          ),
          SizedBox(height: 8),
          if (showAll == true) getDefinitionWidget(),
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
                  child: FutureBuilder(
                      future: vnExampleSentence,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data.length == 0)
                            return ExampleSentenceWidget(
                                exampleSentence: enExampleSentence);
                          return ExampleSentenceWidget(
                            exampleSentence: vnExampleSentence,
                          );
                        } else
                          return SizedBox();
                      }),
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
                    kanjiComponent: KanjiHelper.getKanjiComponent(
                      word: currentCard.word ?? currentCard.slug,
                      context: context,
                    ),
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
              // Again button
              GestureDetector(
                onTap: () async {
                  // Prepare for redo button
                  redo = OfflineWordRecord(
                    slug: currentCard.slug,
                    is_common: currentCard.is_common,
                    tags: currentCard.tags,
                    jlpt: currentCard.jlpt,
                    word: currentCard.word,
                    reading: currentCard.reading,
                    senses: currentCard.senses,
                    vietnamese_definition: currentCard.vietnamese_definition,
                    added: currentCard.added,
                    firstReview: currentCard.firstReview,
                    lastReview: currentCard.lastReview,
                    due: currentCard.due,
                    interval: currentCard.interval,
                    ease: currentCard.ease,
                    reviews: currentCard.reviews,
                    lapses: currentCard.lapses,
                    averageTimeMinute: currentCard.averageTimeMinute,
                    totalTimeMinute: currentCard.totalTimeMinute,
                    cardType: currentCard.cardType,
                    noteType: currentCard.noteType,
                    deck: currentCard.deck,
                  );
                  redoType = RedoType.update;

                  // Calculate and update card interval
                  if (currentCard.reviews == 0) {
                    currentCard.firstReview =
                        DateTime.now().millisecondsSinceEpoch;
                  } else {
                    // If card is mature
                    if (currentCard.interval > 21 * 24 * 60 * 60 * 1000) {
                      currentCard.lapses++;
                      if (currentCard.lapses ==
                          SharedPref.prefs.getInt('leechThreshold')) {
                        print('Card lapses reached. Deleting');
                        redoType = RedoType.delete;
                        DbHelper.addToOfflineList(
                          offlineListType: OfflineListType.favorite,
                          offlineWordRecord: currentCard,
                          context: context,
                        );
                        DbHelper.removeFromOfflineList(
                          offlineListType: OfflineListType.review,
                          context: context,
                          word: currentCard.word,
                        );
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => CustomDialog(
                                  word: currentCard.word ?? currentCard.slug,
                                  message:
                                      'Card has reached lapses threshold (${SharedPref.prefs.getInt('leechThreshold')} times wrong) and has been moved to your favorite list since you probably need to revisit it.',
                                ));
                        showAll = false;
                        if (dictionary.getCards.length > 0) {
                          currentCard = dictionary.getCards[0];
                          updateAdditionalInfo();
                        }
                        setState(() {});
                        return;
                      }
                    }
                  }
                  currentCard.lastReview =
                      DateTime.now().millisecondsSinceEpoch;
                  currentCard.interval = steps[0] * 60 * 1000;
                  currentCard.due = DateTime.now().millisecondsSinceEpoch +
                      currentCard.interval;
                  currentCard.reviews++;

                  DbHelper.updateWordInfo(
                      offlineListType: OfflineListType.review,
                      context: context,
                      senses: jsonDecode(currentCard.senses),
                      offlineWordRecord: currentCard);
                  // dictionary.review = await dictionary.offlineDatabase.retrieve(tableName: 'review');
                  showAll = false;
                  if (dictionary.getCards.length > 0) {
                    currentCard = dictionary.getCards[0];
                    updateAdditionalInfo();
                  }
                  setState(() {});
                },
                child: AnswerButton(
                    offlineWordRecord: currentCard,
                    steps: steps,
                    buttonText: 'Again',
                    color: Colors.red),
              ),

              // Good button
              GestureDetector(
                onTap: () async {
                  // Prepare for redo button
                  redo = OfflineWordRecord(
                    slug: currentCard.slug,
                    is_common: currentCard.is_common,
                    tags: currentCard.tags,
                    jlpt: currentCard.jlpt,
                    word: currentCard.word,
                    reading: currentCard.reading,
                    senses: currentCard.senses,
                    vietnamese_definition: currentCard.vietnamese_definition,
                    added: currentCard.added,
                    firstReview: currentCard.firstReview,
                    lastReview: currentCard.lastReview,
                    due: currentCard.due,
                    interval: currentCard.interval,
                    ease: currentCard.ease,
                    reviews: currentCard.reviews,
                    lapses: currentCard.lapses,
                    averageTimeMinute: currentCard.averageTimeMinute,
                    totalTimeMinute: currentCard.totalTimeMinute,
                    cardType: currentCard.cardType,
                    noteType: currentCard.noteType,
                    deck: currentCard.deck,
                  );
                  redoType = RedoType.update;

                  // Calculate and update card interval
                  currentCard.lastReview =
                      DateTime.now().millisecondsSinceEpoch;
                  if (currentCard.reviews == 0)
                    currentCard.firstReview =
                        DateTime.now().millisecondsSinceEpoch;
                  if (currentCard.interval <
                      steps[steps.length - 1] * 60 * 1000)
                    for (int i = 0; i < steps.length; i++) {
                      if (currentCard.interval < steps[i] * 60 * 1000) {
                        currentCard.interval = steps[i] * 60 * 1000;
                        break;
                      }
                    }
                  else if (currentCard.interval ==
                      steps[steps.length - 1] * 60 * 1000) {
                    currentCard.interval =
                        SharedPref.prefs.getInt('graduatingInterval') *
                            24 *
                            60 *
                            60 *
                            1000;
                  } else if (currentCard.interval >=
                      SharedPref.prefs.getInt('graduatingInterval') *
                          24 *
                          60 *
                          60 *
                          1000) {
                    currentCard.interval =
                        (currentCard.interval * currentCard.ease).round();
                  }

                  currentCard.due = currentCard.interval +
                      DateTime.now().millisecondsSinceEpoch;
                  currentCard.reviews++;

                  DbHelper.updateWordInfo(
                    offlineListType: OfflineListType.review,
                    context: context,
                    senses: jsonDecode(currentCard.senses),
                    offlineWordRecord: currentCard,
                  );
                  showAll = false;
                  if (dictionary.getCards.length > 0) {
                    currentCard = dictionary.getCards[0];
                    updateAdditionalInfo();
                  }
                  setState(() {});
                },
                child: AnswerButton(
                    offlineWordRecord: currentCard,
                    steps: steps,
                    buttonText: 'Good',
                    color: Colors.green),
              )
            ],
          ),
        ),
    ]);
  }

  getDefinitionWidget() {
    if (currentCard.vietnamese_definition != null)
      return DefinitionWidget(
        senses: jsonDecode(currentCard.senses),
        vietnameseDefinition: currentCard.vietnamese_definition,
      );
    else
      return FutureBuilder(
          future: getVietnameseDefinition(currentCard.word ?? currentCard.slug),
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Center(
                child: DefinitionWidget(
                  senses: jsonDecode(currentCard.senses),
                  vietnameseDefinition: null,
                ),
              );
            return Center(
              child: DefinitionWidget(
                senses: jsonDecode(currentCard.senses),
                vietnameseDefinition: snapshot.data.definition,
              ),
            );
          });
  }

  void updateAdditionalInfo() {
    getVietnameseDefinition(currentCard.word ?? currentCard.slug);
    hanViet =
        KanjiHelper.getHanvietReading(word: currentCard.word, context: context);
    enExampleSentence = KanjiHelper.getExampleSentence(
        word: currentCard.word,
        context: context,
        tableName: 'englishExampleDictionary');
    vnExampleSentence = KanjiHelper.getExampleSentence(
        word: currentCard.word,
        context: context,
        tableName: 'exampleDictionary');
  }
}
