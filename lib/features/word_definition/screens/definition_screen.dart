import 'dart:convert';
import 'package:collection/collection.dart';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/example_sentence.dart';
import '../../../models/kanji.dart';
import '../../../models/offline_word_record.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/db_helper.dart';
import '../../../services/kanji_helper.dart';
import '../../../utils/offline_list_type.dart';
import '../../../core/data/datasources/shared_pref.dart';
import '../../../widgets/definition_screen/component_widget.dart';
import '../../../widgets/definition_screen/definition_tags.dart';
import '../../../widgets/definition_screen/definition_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widgets/definition_screen/example_sentence_widget.dart';
import '../../main_search/domain/entities/jisho_definition.dart';

class DefinitionScreenArgs {
  final Future<List<String>>? hanViet;
  final VietnameseDefinition? vnDefinition;
  final TextEditingController textEditingController;
  final JishoDefinition? jishoDefinition;
  final bool isInFavoriteList;
  final bool isOfflineList;
  DefinitionScreenArgs({
    this.hanViet,
    this.vnDefinition,
    required this.textEditingController,
    this.jishoDefinition,
    required this.isInFavoriteList,
    this.isOfflineList = false,
  });
}


class DefinitionScreen extends StatefulWidget {
  final DefinitionScreenArgs args;
  DefinitionScreen({
    required this.args,
  });

  @override
  _DefinitionScreenState createState() => _DefinitionScreenState();
}

class _DefinitionScreenState extends State<DefinitionScreen> {
  bool isClipboardSet = false;
  late String clipboard;
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiList;
  late Future<List<ExampleSentence>> exampleSentence;
  late OfflineWordRecord offlineWordRecord;
  late String word;

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    word = widget.args.vnDefinition?.word ?? '';
    if (word.isEmpty) {
      word = widget.args.jishoDefinition?.word ?? '';
    }
    if (word.isEmpty) {
      word = widget.args.jishoDefinition?.slug ?? '';
    }
    offlineWordRecord = OfflineWordRecord(
      slug: word,
      isCommon: widget.args.jishoDefinition?.isCommon == true ? 1 : 0,
      tags: jsonEncode(widget.args.jishoDefinition?.tags),
      jlpt: jsonEncode(widget.args.jishoDefinition?.jlpt),
      word: word ,
      reading: widget.args.jishoDefinition?.reading ?? '',
      senses: jsonEncode(widget.args.jishoDefinition?.senses),
      vietnameseDefinition: widget.args.vnDefinition?.definition ?? '',
      added: DateTime.now().millisecondsSinceEpoch,
      firstReview: null,
      lastReview: null,
      due: -1,
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
      word: widget.args.jishoDefinition?.word,
      slug: widget.args.jishoDefinition?.slug,
      reading: widget.args.jishoDefinition?.reading,
      context: context,
    );

    kanjiList = KanjiHelper.getKanjiComponent(
        word: word,
        context: context);

    try {
      final lang = getIt<SharedPref>().prefs.getString('language');
      if (lang?.contains('English') == true)
        exampleSentence = KanjiHelper.getExampleSentence(
            word: word,
            context: context,
            tableName: 'englishExampleDictionary');
      else if (lang == 'Tiếng Việt') {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: word,
            context: context,
            tableName: 'exampleDictionary');
      }
    } catch (e) {
      print('Error getting example sentence $e');
    }
    getClipboard();
    widget.args.textEditingController.addListener(() {
      if (mounted) {
        if (clipboard != widget.args.textEditingController.text) {
          clipboard = widget.args.textEditingController.text;
          Navigator.of(context).popUntil((route) => route.isFirst);
          print('Definition screen popped');
        }
      }
    });
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
                    word: word,
                    context: context)
                ? Icon(Icons.favorite, color: Colors.white)
                : Icon(Icons.favorite_border),
            onPressed: () {
              if (DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.favorite,
                      word: word,
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
                      word: word);
                });
            },
          ),
          IconButton(
            padding: EdgeInsets.only(left: 20, right: 20),
            icon: DbHelper.checkDatabaseExist(
                    offlineListType: OfflineListType.review,
                    word: word,
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
                      word: word,
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
                      word: word);
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
          FutureBuilder<List<Widget>>(
            future: pitchAccent,
            builder: (context, snapshot) {
              if (snapshot.data == null)
                return Text(
                  widget.args.jishoDefinition?.reading ?? '',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey,
                  ),
                );
              return Row(
                children: snapshot.data!,
              );
            },
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  word,
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
                            AppLocalizations.of(context)!.views,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          getIt<SharedPref>().prefs.getString('language') == ('Tiếng Việt')
              ? FutureBuilder<List<String>>(
                  future: widget.args.hanViet,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data!.length == 0)
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
              widget.args.jishoDefinition?.isCommon == true
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
                  tags: widget.args.jishoDefinition?.tags ?? [], color: Color(0xFF909DC0)),
              DefinitionTags(
                  tags: widget.args.jishoDefinition?.jlpt ?? [], color: Color(0xFF909DC0)),
            ],
          ),
          SizedBox(height: 8),
          DefinitionWidget(
            senses: widget.args.jishoDefinition?.senses,
            vietnameseDefinition: widget.args.vnDefinition?.definition,
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
          FutureBuilder<List<ExampleSentence>>(
              future: exampleSentence,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data?.length == 0)
                    return ExampleSentenceWidget(
                      exampleSentence: KanjiHelper.getExampleSentence(
                          word: word,
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
    OfflineWordRecord? found;
    try {
      found = getIt<Dictionary>().history.firstWhereOrNull((element) {
        String elementWord = element.word;
        if (elementWord.isEmpty) {
          elementWord = element.slug;
        }
        return elementWord == word;
      });
    } catch (e) {
      print('Word not in history: $e');
    }
    if (found == null)
      return 0;
    else
      return found.reviews;
  }
}
