import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
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
import '../../main_search/domain/entities/jisho_definition.dart';
import '../../main_search/presentation/bloc/main_search_bloc.dart';
import 'widgets/component_widget.dart';
import 'widgets/definition_widget.dart';
import 'widgets/example_sentence_widget.dart';
import 'widgets/is_common_tag_and_jlpt.dart';

class DefinitionScreenArgs {
  MainSearchBloc mainSearchBloc;
  final List<String>? hanViet;
  final VietnameseDefinition? vnDefinition;
  final JishoDefinition? jishoDefinition;
  final bool isInFavoriteList;
  final bool isOfflineList;
  DefinitionScreenArgs({
    required this.mainSearchBloc,
    this.hanViet,
    this.vnDefinition,
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

  static BlocProvider<MainSearchBloc> provider({
    required DefinitionScreenArgs args,
  }) {
    return BlocProvider.value(
      value: args.mainSearchBloc,
      child: DefinitionScreen(args: args),
    );
  }

  @override
  _DefinitionScreenState createState() => _DefinitionScreenState();
}

class _DefinitionScreenState extends State<DefinitionScreen> {
  bool isClipboardSet = false;
  late String clipboard;
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiList;
  late Future<List<ExampleSentence>> exampleSentence;
  late JishoDefinition jishoDefinition;
  late VietnameseDefinition vnDefinition;
  late OfflineWordRecord offlineWordRecord;
  late String currentJapaneseWord;

  Widget getPartsOfSpeech(List<dynamic> partsOfSpeech) {
    if (partsOfSpeech.length > 0) {
      return Text(
        partsOfSpeech.first.toString().toUpperCase(),
      );
    }
    return SizedBox();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    jishoDefinition = widget.args.jishoDefinition ?? JishoDefinition(slug: '');
    vnDefinition = widget.args.vnDefinition ?? VietnameseDefinition();
    currentJapaneseWord = vnDefinition.word;
    if (widget.args.jishoDefinition != null) {
      _saveHistoryOfflineWordRecord(context);
    }
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

    kanjiList = KanjiHelper.getKanjiComponent(word: currentJapaneseWord);

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
                ? Icon(Icons.bookmark, color: Colors.white)
                : Icon(Icons.bookmark_border),
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
              if (snapshot.data == null || snapshot.data?.isEmpty == true)
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
          if (getIt<SharedPref>().isAppInVietnamese &&
              widget.args.hanViet?.isNotEmpty == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.args.hanViet.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          widget.args.jishoDefinition != null
              ? IsCommonTagsAndJlptWidget(
                  isCommon: jishoDefinition.isCommon,
                  tags: jishoDefinition.tags,
                  jlpt: jishoDefinition.jlpt,
                )
              :  
          BlocConsumer<MainSearchBloc, MainSearchState>(
            listener: (context, state) {
              if (state is MainSearchAllLoadedState) {
                jishoDefinition = state.data.getSpecificJishoDefinition(
                        japaneseWord: currentJapaneseWord) ??
                    JishoDefinition(slug: "");
                _saveHistoryOfflineWordRecord(context);
              }
            },
            builder: (context, state) {
              final jishoDefinition = state.data.getSpecificJishoDefinition(
                  japaneseWord: currentJapaneseWord);
              final isCommon = jishoDefinition?.isCommon ?? false;
              final tags = jishoDefinition?.tags ?? [];
              final jlpt = jishoDefinition?.jlpt ?? [];
              
              return IsCommonTagsAndJlptWidget(
                isCommon: isCommon,
                tags: tags,
                jlpt: jlpt,
              );
            },
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

  void _saveHistoryOfflineWordRecord(BuildContext context) {
    DbHelper.addToOfflineList(
        offlineListType: OfflineListType.history,
        offlineWordRecord: OfflineWordRecord(
          slug: currentJapaneseWord,
          isCommon: jishoDefinition.isCommon == true ? 1 : 0,
          tags: jishoDefinition.tags,
          jlpt: jishoDefinition.jlpt,
          word: currentJapaneseWord,
          reading: jishoDefinition.reading ?? '',
          senses: jishoDefinition.senses,
          vietnameseDefinition: vnDefinition.definition,
          added: DateTime.now().millisecondsSinceEpoch,
          firstReview: null,
          lastReview: null,
          due: -1,
          interval: 0,
          ease: getIt<SharedPref>().prefs.getDouble('startingEase') ?? -1,
          reviews: 0,
          lapses: 0,
          averageTimeMinute: 0,
          totalTimeMinute: 0,
          cardType: 'default',
          noteType: 'default',
          deck: 'default',
        ),
        context: context);
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

