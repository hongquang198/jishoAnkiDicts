import 'dart:convert';
import '../../../models/dictionary.dart';
import '../../../models/exampleSentence.dart';
import '../../../models/jishoDefinition.dart';
import '../../../models/kanji.dart';
import '../../../models/offlineWordRecord.dart';
import '../../../models/vietnameseDefinition.dart';
import '../../../services/dbHelper.dart';
import '../../../services/kanjiHelper.dart';
import '../../../utils/offlineListType.dart';
import '../../../utils/sharedPref.dart';
import '../../../widgets/definition_screen/component_widget.dart';
import '../../../widgets/definition_screen/definition_tags.dart';
import '../../../widgets/definition_screen/example_sentence_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/definition_screen/definition_widget.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DefinitionScreen extends StatefulWidget {
  final JishoDefinition jishoDefinition;
  final bool isInFavoriteList;
  final TextEditingController textEditingController;
  final bool isOfflineList;
  final VietnameseDefinition vnDefinition;
  final Future<List<String>> hanViet;
  DefinitionScreen({
    this.hanViet,
    this.vnDefinition,
    this.textEditingController,
    this.jishoDefinition,
    this.isInFavoriteList,
    this.isOfflineList,
  });

  @override
  _DefinitionScreenState createState() => _DefinitionScreenState();
}

class _DefinitionScreenState extends State<DefinitionScreen> {
  bool isClipboardSet = false;
  String clipboard;
  Future<List<Widget>> pitchAccent;
  Future<List<Kanji>> kanjiList;
  Future<List<ExampleSentence>> exampleSentence;
  OfflineWordRecord offlineWordRecord;

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
    return data.text;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    offlineWordRecord = OfflineWordRecord(
      slug: widget.jishoDefinition.slug ?? widget.jishoDefinition.word,
      isCommon: widget.jishoDefinition.isCommon == true ? 1 : 0,
      tags: jsonEncode(widget.jishoDefinition.tags),
      jlpt: jsonEncode(widget.jishoDefinition.jlpt),
      word: widget.vnDefinition.word ??
          widget.jishoDefinition.word ??
          widget.jishoDefinition.slug,
      reading: widget.jishoDefinition.reading,
      senses: jsonEncode(widget.jishoDefinition.senses),
      vietnameseDefinition: widget.vnDefinition.definition,
      added: DateTime.now().millisecondsSinceEpoch,
      firstReview: null,
      lastReview: null,
      due: null,
      interval: 0,
      ease: 2.5,
      reviews: 0,
      lapses: 0,
      averageTimeMinute: 0,
      totalTimeMinute: 0,
      cardType: 'default',
      noteType: 'default',
      deck: 'default',
    );
    pitchAccent = KanjiHelper.getPitchAccent(
      word: widget.jishoDefinition.word,
      slug: widget.jishoDefinition.slug,
      reading: widget.jishoDefinition.reading,
      context: context,
    );

    kanjiList = KanjiHelper.getKanjiComponent(
        word: widget.vnDefinition.word ??
            widget.jishoDefinition.word ??
            widget.jishoDefinition.slug ??
            '',
        context: context);

    try {
      if (SharedPref.prefs.getString('language').contains('English'))
        exampleSentence = KanjiHelper.getExampleSentence(
            word: widget.vnDefinition.word ?? widget.jishoDefinition.word,
            context: context,
            tableName: 'englishExampleDictionary');
      else if (SharedPref.prefs.getString('language') == 'Tiếng Việt') {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: widget.vnDefinition.word ?? widget.jishoDefinition.word,
            context: context,
            tableName: 'exampleDictionary');
      }
    } catch (e) {
      print('Error getting example sentence $e');
    }
    getClipboard();
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            padding: EdgeInsets.all(0),
            icon: DbHelper.checkDatabaseExist(
                    offlineListType: OfflineListType.favorite,
                    word: widget.jishoDefinition.word ??
                        widget.jishoDefinition.slug,
                    context: context)
                ? Icon(Icons.favorite, color: Colors.white)
                : Icon(Icons.favorite_border),
            onPressed: () {
              if (DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.favorite,
                      word: widget.jishoDefinition.word ??
                          widget.jishoDefinition.slug,
                      context: context) ==
                  false) {
                setState(() {
                  DbHelper.addToOfflineList(
                      offlineListType: OfflineListType.favorite,
                      offlineWordRecord: offlineWordRecord,
                      context: context);
                });
              } else
                setState(() {
                  DbHelper.removeFromOfflineList(
                      offlineListType: OfflineListType.favorite,
                      context: context,
                      word: widget.jishoDefinition.word ??
                          widget.jishoDefinition.slug);
                });
            },
          ),
          IconButton(
            padding: EdgeInsets.only(left: 20, right: 20),
            icon: DbHelper.checkDatabaseExist(
                    offlineListType: OfflineListType.review,
                    word: widget.vnDefinition.word ??
                        widget.jishoDefinition.word ??
                        widget.jishoDefinition.slug,
                    context: context)
                ? Icon(
                    Icons.alarm_on_rounded,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.alarm_add,
                  ),
            onPressed: () {
              if (DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.review,
                      word: widget.vnDefinition.word ??
                          widget.jishoDefinition.word ??
                          widget.jishoDefinition.slug,
                      context: context) ==
                  false) {
                setState(() {
                  DbHelper.addToOfflineList(
                      offlineListType: OfflineListType.review,
                      offlineWordRecord: offlineWordRecord,
                      context: context);
                });
              } else
                setState(() {
                  DbHelper.removeFromOfflineList(
                      offlineListType: OfflineListType.review,
                      context: context,
                      word: widget.jishoDefinition.word ??
                          widget.jishoDefinition.slug);
                });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          FutureBuilder(
            future: pitchAccent,
            builder: (context, snapshot) {
              if (snapshot.data == null)
                return Text(
                  widget.jishoDefinition.reading ?? '',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey,
                  ),
                );
              return Row(
                children: snapshot.data,
              );
            },
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.vnDefinition.word ??
                      widget.jishoDefinition.word ??
                      widget.jishoDefinition.slug,
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  child: Center(
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('${getViewCounts()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            AppLocalizations.of(context).views,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          SharedPref.prefs.getString('language') == ('Tiếng Việt')
              ? FutureBuilder(
                  future: widget.hanViet,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data.length == 0)
                      return SizedBox();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          snapshot.data.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    );
                  },
                )
              : SizedBox(),
          Row(
            children: <Widget>[
              widget.jishoDefinition.isCommon == true
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
                  tags: widget.jishoDefinition.tags, color: Color(0xFF909DC0)),
              DefinitionTags(
                  tags: widget.jishoDefinition.jlpt, color: Color(0xFF909DC0)),
            ],
          ),
          SizedBox(height: 8),
          DefinitionWidget(
            senses: widget.jishoDefinition.senses,
            vietnameseDefinition: widget.vnDefinition.definition,
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
          FutureBuilder(
              future: exampleSentence,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data.length == 0)
                    return ExampleSentenceWidget(
                      exampleSentence: KanjiHelper.getExampleSentence(
                          word: widget.vnDefinition.word ??
                              widget.jishoDefinition.word,
                          context: context,
                          tableName: 'englishExampleDictionary'),
                    );
                  return ExampleSentenceWidget(
                    exampleSentence: exampleSentence,
                  );
                } else
                  return SizedBox();
              }),
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

  int getViewCounts() {
    OfflineWordRecord found;
    try {
      found = Provider.of<Dictionary>(context).history.firstWhere((element) =>
          (element.word ?? element.slug) ==
          (widget.vnDefinition.word ??
              widget.jishoDefinition.word ??
              widget.jishoDefinition.slug));
    } catch (e) {
      print('Word not in history: $e');
    }
    if (found == null)
      return 0;
    else
      return found.reviews;
  }
}
