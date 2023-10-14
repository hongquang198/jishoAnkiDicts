import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/example_sentence.dart';
import '../../../models/kanji.dart';
import '../../../models/offline_word_record.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../utils/redo_type.dart';
import '../../../core/data/datasources/shared_pref.dart';
import '../../../services/db_helper.dart';
import '../../../services/kanji_helper.dart';
import '../../../utils/offline_list_type.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/review_screen/answer_button.dart';
import '../../../widgets/review_screen/review_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../card_info/screens/card_info_screen.dart';
import '../../word_definition/screens/widgets/component_widget.dart';
import '../../word_definition/screens/widgets/definition_tags.dart';
import '../../word_definition/screens/widgets/definition_widget.dart';
import '../../word_definition/screens/widgets/example_sentence_widget.dart';

class ReviewScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  ReviewScreen({required this.textEditingController});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late int totalCardNumber;
  late String clipboard;
  bool showAll = false;
  late List<int> steps;
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiComponent;
  late Future<List<String>> hanViet;
  late OfflineWordRecord? redo;
  late OfflineWordRecord currentCard;
  late RedoType redoType;
  late Future<List<ExampleSentence>> enExampleSentence;
  late Future<List<ExampleSentence>> vnExampleSentence;

  Widget getPartsOfSpeech(List<dynamic> partsOfSpeech) {
    if (partsOfSpeech.length > 0) {
        return Text(
          partsOfSpeech.first.toString().toUpperCase(),
        );
    }
    return SizedBox();
  }

  Future<String> getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    clipboard = data?.text ?? '';
    return clipboard;
  }

  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnList = [];
    try {
      vnList = await KanjiHelper.getVnDefinition(word: word);
      return vnList[0];
    } catch (e) {
      print('No VN definition found $e');
      return vnList[0];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // getKanjiComponent() async {
  //   kanjiComponent = KanjiHelper.getKanjiComponent(
  //       word: getIt<Dictionary>()
  //               .getCards[currentCard]
  //               .word ??
  //           getIt<Dictionary>()
  //               .getCards[currentCard]
  //               .slug,
  //       context: context);
  // }
  //
  // drawPitchAccent() async {
  //   pitchAccent = KanjiHelper.getPitchAccent(
  //       word: getIt<Dictionary>()
  //           .getCards[currentCard]
  //           .word,
  //       slug: getIt<Dictionary>()
  //           .getCards[currentCard]
  //           .slug,
  //       reading: getIt<Dictionary>()
  //           .getCards[currentCard]
  //           .reading,
  //       context: context);
  //   return pitchAccent;
  // }

  @override
  void initState() {
    // Get steps from settings to calculate card's next interval
    steps = getIt<SharedPref>().prefs
        .getStringList('newCardsSteps')
        ?.map((i) => int.parse(i))
        .toList() ?? [];

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
      currentCard = getIt<Dictionary>().getCards[0];
      redo = currentCard;
      updateAdditionalInfo();
    } catch (e) {
      print('Card empty. $e');
    }

    getClipboard();
    super.initState();
  }
  String get word => currentCard.word.isEmpty ? currentCard.slug : currentCard.word;

  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.review),
          actions: [
            GestureDetector(
                onTap: () async {
                  if (redo != null) currentCard = redo!;
                  if (redoType == RedoType.update) {
                    DbHelper.updateWordInfo(
                        offlineListType: OfflineListType.review,
                        context: context,
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
                  if (dictionary.getCards.length > 0) {
                    redo = OfflineWordRecord(
                      slug: currentCard.slug,
                      isCommon: currentCard.isCommon,
                      tags: currentCard.tags,
                      jlpt: currentCard.jlpt,
                      word: currentCard.word,
                      reading: currentCard.reading,
                      senses: currentCard.senses,
                      vietnameseDefinition: currentCard.vietnameseDefinition,
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
                  dictionary.getCards.length > 0
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
          bottom: dictionary.getCards.length > 0
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
                child: Text(AppLocalizations.of(context)!.reviewComplete),
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
              ? FutureBuilder<List<Widget>>(
                  future: KanjiHelper.getPitchAccent(
                      word: currentCard.word,
                      slug: currentCard.slug,
                      reading: currentCard.reading,
                      context: context),
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return Center(
                        child: Text(
                          currentCard.reading,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: snapshot.data ?? [],
                    );
                  },
                )
              : SizedBox(),
          Center(
            child: Text(
              currentCard.japaneseWord,
              style: TextStyle(
                fontSize: 45.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          showAll == true &&
                  getIt<SharedPref>().isAppInVietnamese
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
              currentCard.isCommon == 1
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
                  tags: currentCard.tags, color: Color(0xFF909DC0)),
              DefinitionTags(
                  tags: currentCard.jlpt, color: Color(0xFF909DC0)),
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
                  child: FutureBuilder<List<ExampleSentence>>(
                      future: vnExampleSentence,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          if (snapshot.data!.length == 0)
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
                      word: currentCard.japaneseWord,
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
                    isCommon: currentCard.isCommon,
                    tags: currentCard.tags,
                    jlpt: currentCard.jlpt,
                    word: currentCard.word,
                    reading: currentCard.reading,
                    senses: currentCard.senses,
                    vietnameseDefinition: currentCard.vietnameseDefinition,
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
                    currentCard = currentCard.copyWith(
                        firstReview: DateTime.now().millisecondsSinceEpoch);
                  } else {
                    // If card is mature
                    if (currentCard.interval > 21 * 24 * 60 * 60 * 1000) {
                      currentCard = currentCard.copyWith(lapses: currentCard.lapses + 1);
                      if (currentCard.lapses ==
                          getIt<SharedPref>().prefs.getInt('leechThreshold')) {
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
                                  word: currentCard.japaneseWord,
                                  message:
                                      'Card has reached lapses threshold (${getIt<SharedPref>().prefs.getInt('leechThreshold')} times wrong) and has been moved to your favorite list since you probably need to revisit it.',
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
                  currentCard = currentCard.copyWith(
                    lastReview: DateTime.now().millisecondsSinceEpoch,
                    interval: steps[0] * 60 * 1000,
                    due: DateTime.now().millisecondsSinceEpoch +
                      currentCard.interval,
                    reviews: currentCard.reviews + 1
                  );

                  DbHelper.updateWordInfo(
                      offlineListType: OfflineListType.review,
                      context: context,
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
                    isCommon: currentCard.isCommon,
                    tags: currentCard.tags,
                    jlpt: currentCard.jlpt,
                    word: currentCard.word,
                    reading: currentCard.reading,
                    senses: currentCard.senses,
                    vietnameseDefinition: currentCard.vietnameseDefinition,
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
                  currentCard = currentCard.copyWith(
                    lastReview: DateTime.now().millisecondsSinceEpoch
                  );
                  if (currentCard.reviews == 0) {
                    currentCard = currentCard.copyWith(
                      firstReview: DateTime.now().millisecondsSinceEpoch
                    );
                  }
                  if (currentCard.interval <
                      steps[steps.length - 1] * 60 * 1000)
                    for (int i = 0; i < steps.length; i++) {
                      if (currentCard.interval < steps[i] * 60 * 1000) {
                        currentCard = currentCard.copyWith(
                          interval: steps[i] * 60 * 1000
                        );
                        break;
                      }
                    }
                  else if (currentCard.interval ==
                      steps[steps.length - 1] * 60 * 1000) {
                    currentCard = currentCard.copyWith(
                        interval: getIt<SharedPref>()
                                .prefs
                                .getInt('graduatingInterval')! *
                            24 *
                            60 *
                            60 *
                            1000);
                  } else if (currentCard.interval >=
                      getIt<SharedPref>().prefs.getInt('graduatingInterval')! *
                          24 *
                          60 *
                          60 *
                          1000) {
                    currentCard = currentCard.copyWith(
                        interval:
                            (currentCard.interval * currentCard.ease).round());
                  }
                  currentCard = currentCard.copyWith(
                    due: currentCard.interval +
                      DateTime.now().millisecondsSinceEpoch,
                    reviews: currentCard.reviews + 1
                  );

                  DbHelper.updateWordInfo(
                    offlineListType: OfflineListType.review,
                    context: context,
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
    if (currentCard.vietnameseDefinition.isNotEmpty)
      return DefinitionWidget(
        senses: currentCard.senses,
        vietnameseDefinition: currentCard.vietnameseDefinition,
      );
    else
      return FutureBuilder<VietnameseDefinition>(
          future: getVietnameseDefinition(word),
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Center(
                child: DefinitionWidget(
                  senses: currentCard.senses,
                  vietnameseDefinition: null,
                ),
              );
            return Center(
              child: DefinitionWidget(
                senses: currentCard.senses,
                vietnameseDefinition: snapshot.data?.definition,
              ),
            );
          });
  }

  void updateAdditionalInfo() {
    getVietnameseDefinition(word);
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
