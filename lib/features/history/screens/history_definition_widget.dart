import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

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
import '../../../widgets/definition_screen/definition_widget.dart';

import '../../../widgets/definition_screen/example_sentence_widget.dart';
import '../../main_search/domain/entities/jisho_definition.dart';
import '../../word_definition/screens/widgets/is_common_tag_and_jlpt.dart';

class SavedDefinitionScreenArgs {
  final Future<List<String>>? hanViet;
  final VietnameseDefinition? vnDefinition;
  //  TODO (@hongquang198): Remove textEditingController
  final TextEditingController textEditingController;
  final JishoDefinition? jishoDefinition;
  final bool isInFavoriteList;
  final bool isOfflineList;
  SavedDefinitionScreenArgs({
    this.hanViet,
    this.vnDefinition,
    required this.textEditingController,
    this.jishoDefinition,
    required this.isInFavoriteList,
    this.isOfflineList = false,
  });
}

class SavedDefinitionScreen extends StatefulWidget {
  final SavedDefinitionScreenArgs args;
  SavedDefinitionScreen({
    required this.args,
  });

  @override
  _SavedDefinitionScreenState createState() => _SavedDefinitionScreenState();
}

class _SavedDefinitionScreenState extends State<SavedDefinitionScreen> {
  bool isClipboardSet = false;
  late String clipboard;
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiList;
  late Future<List<ExampleSentence>> exampleSentence;
  late JishoDefinition jishoDefinition;
  late VietnameseDefinition vnDefinition;
  late OfflineWordRecord offlineWordRecord;
  late String currentJapaneseWord;

  Future<String> getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    clipboard = data?.text ?? '';
    return clipboard;
  }

  @override
  void initState() {
    super.initState();
    jishoDefinition = widget.args.jishoDefinition ?? JishoDefinition(slug: '');
    vnDefinition = widget.args.vnDefinition ?? VietnameseDefinition();
    currentJapaneseWord = vnDefinition.word;
    if (currentJapaneseWord.isEmpty) {
      currentJapaneseWord = jishoDefinition.word ?? '';
    }
    if (currentJapaneseWord.isEmpty) {
      currentJapaneseWord = jishoDefinition.slug;
    }
    pitchAccent = KanjiHelper.getPitchAccent(
      word: jishoDefinition.word,
      slug: jishoDefinition.slug,
      reading: jishoDefinition.reading,
      context: context,
    );

    kanjiList = KanjiHelper.getKanjiComponent(word: currentJapaneseWord, context: context);

    try {
      final lang = getIt<SharedPref>().prefs.getString('language');
      if (lang?.contains('English') == true)
        exampleSentence = KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'englishExampleDictionary');
      else if (lang == 'Tiếng Việt') {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: currentJapaneseWord, context: context, tableName: 'exampleDictionary');
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
                    word: currentJapaneseWord,
                    context: context)
                ? Icon(Icons.favorite, color: Colors.white)
                : Icon(Icons.favorite_border),
            onPressed: () {
              if (DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.favorite,
                      word: currentJapaneseWord,
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
                      word: currentJapaneseWord);
                });
            },
          ),
          IconButton(
            padding: EdgeInsets.only(left: 20, right: 20),
            icon: DbHelper.checkDatabaseExist(
                    offlineListType: OfflineListType.review,
                    word: currentJapaneseWord,
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
                      word: currentJapaneseWord,
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
                      word: currentJapaneseWord);
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
                  jishoDefinition.reading ?? '',
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
                  currentJapaneseWord,
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
          getIt<SharedPref>().isAppInVietnamese
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
          if (widget.args.jishoDefinition != null)
              IsCommonTagsAndJlptWidget(
                  isCommon: jishoDefinition.isCommon,
                  tags: jishoDefinition.tags,
                  jlpt: jishoDefinition.jlpt,
                ),
          SizedBox(height: 8),
          DefinitionWidget(
            senses: jishoDefinition.senses,
            vietnameseDefinition: vnDefinition.definition,
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
                          word: currentJapaneseWord,
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
        return elementWord == currentJapaneseWord;
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
