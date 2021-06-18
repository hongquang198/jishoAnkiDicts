import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/models/vietnameseDefinition.dart';
import 'package:JapaneseOCR/themeManager.dart';
import 'package:JapaneseOCR/services/jishoQuery.dart';
import 'dart:async';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:JapaneseOCR/widgets/main_screen/search_result_tile.dart';
import 'package:JapaneseOCR/widgets/nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/services/recognizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:JapaneseOCR/widgets/main_screen/draw_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  TextEditingController textEditingController;

  Timer searchOnStoppedTyping;

  JishoQuery jishoQuery = JishoQuery();
  List<VietnameseDefinition> vnDictQuery = [];
  var jishoData;
  final _recognizer = Recognizer();
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";

  Timer clipboardTriggerTime;
  String clipboard;

  _search() async {
    if (SharedPref.prefs.getString('language') == ('Tiếng Việt'))
      await getVnDictQuery(textEditingController.text);
    jishoData = jishoQuery.getJishoQuery(textEditingController.text);
  }

  Future _initModel({String modelFilePath, String labelFilePath}) async {
    var res = await _recognizer.loadModel(
        modelPath: modelFilePath, labelPath: labelFilePath);
  }


  @override
  void initState() {
    textEditingController = TextEditingController();
    jishoData = jishoQuery.getJishoQuery('辞書');
    getVnDictQuery('辞書');
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
    clipboardTriggerTime =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
      Clipboard.getData('text/plain').then((clipboardContent) {
        if (clipboard != clipboardContent.text) {
          clipboard = clipboardContent.text;
          textEditingController.text = clipboard;
          _search();
          setState(() {});
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word, context: context);
    return vnDefinition[0];
  }

  Future<List<VietnameseDefinition>> getVnDictQuery(String word) async {
    vnDictQuery = await Provider.of<Dictionary>(context, listen: false)
        .offlineDatabase
        .searchForVnMeaning(word: word);
    setState(() {});
    return vnDictQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) =>
      Scaffold(
      drawer: NavBar(
        textEditingController: textEditingController,
      ),
      appBar: AppBar(
        leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu_rounded),
              color: Constants.appBarIconColor,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
        ),
        title: Text(
          AppLocalizations.of(context).appTitle,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    onSubmitted: (valueChanged) async {
                      await _search();
                      setState(() {});
                    },
                    style: TextStyle(color: Constants.appBarTextColor),
                    controller: textEditingController,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        color: Constants.appBarTextColor,
                        onPressed: () async {
                          await _search();
                          setState(() {});
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Constants.appBarIconColor,
                        ),
                        onPressed: () {
                          setState(() {
                            textEditingController.text = '';
                          });
                        },
                      ),
                      hintText: "Search for a word",
                      hintStyle: TextStyle(color: Constants.appBarTextColor),
                      labelStyle: TextStyle(color: Constants.appBarTextColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.only(bottom: 10),
                icon: Icon(Icons.brush),
                color: Constants.appBarIconColor,
                onPressed: () {
                  setState(() {
                    textEditingController.text = '';
                  });
                  showModalBottomSheet(
                      isScrollControlled: true,
                      enableDrag: false,
                      context: context,
                      builder: (ctx) {
                        return Wrap(children: <Widget>[
                          Container(
                            color: Color(0xFFf8f1f1),
                            height: 400,
                            child: DrawScreen(
                                textEditingController: textEditingController),
                          ),
                        ]);
                      });
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: getSearchResultTiles(),
      ),
    ));
  }

  getSearchResultTiles() {
    if (SharedPref.prefs.getString('language') == ('Tiếng Việt') &&
        vnDictQuery.length != 0) {
      return ListView.separated(
        separatorBuilder: (context, index) => Divider(
          thickness: 0.4,
        ),
        itemCount: vnDictQuery.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
              future: jishoData,
              builder: (context, jishoSnapshot) {
                SearchResultTile searchResultTileOldWaiting = SearchResultTile(
                  loadingDefinition: true,
                  jishoDefinition: JishoDefinition(
                    slug: '',
                    is_common: false,
                    tags: [],
                    jlpt: [],
                    word: 'waiting',
                    reading: '',
                    senses: jsonDecode(
                        '[{"english_definitions":[],"parts_of_speech":[],"links":[],"tags":[],"restrictions":[],"see_also":[],"antonyms":[],"source":[],"info":[]}]'),
                    is_jmnedict: '',
                    is_dbpedia: '',
                    is_jmdict: '',
                  ),
                  textEditingController: textEditingController,
                  hanViet: KanjiHelper.getHanvietReading(
                      word: vnDictQuery[index].word, context: context),
                  vnDefinition: vnDictQuery[index],
                  // ignore: missing_return
                );
                SearchResultTile searchResultTileFinished = SearchResultTile(
                  loadingDefinition: false,
                  jishoDefinition: JishoDefinition(
                    slug: '',
                    is_common: false,
                    tags: [],
                    jlpt: [],
                    word: 'waiting',
                    reading: '',
                    senses: jsonDecode(
                        '[{"english_definitions":[],"parts_of_speech":[],"links":[],"tags":[],"restrictions":[],"see_also":[],"antonyms":[],"source":[],"info":[]}]'),
                    is_jmnedict: '',
                    is_dbpedia: '',
                    is_jmdict: '',
                  ),
                  textEditingController: textEditingController,
                  hanViet: KanjiHelper.getHanvietReading(
                      word: vnDictQuery[index].word, context: context),
                  vnDefinition: vnDictQuery[index],
                  // ignore: missing_return
                );
                if (jishoSnapshot.connectionState == ConnectionState.done && jishoSnapshot.data != null) {
                  bool gotWordInfo = false;
                  int i = 0;
                  for (i = 0; i < jishoSnapshot.data['data'].length; i++) {
                    if (jishoSnapshot.data['data'][i]['japanese'][0]['word'] ==
                            vnDictQuery[index].word ??
                        jishoSnapshot.data['data'][i]['slug'] ==
                            vnDictQuery[index].word) {
                      gotWordInfo = true;
                      break;
                    }
                  }

                  if (gotWordInfo == true)
                    return SearchResultTile(
                      loadingDefinition: false,
                      jishoDefinition: JishoDefinition(
                          slug: jishoSnapshot.data['data'][i]['slug'],
                          is_common:
                              jishoSnapshot.data['data'][i]['is_common'] == null
                                  ? false
                                  : jishoSnapshot.data['data'][i]['is_common'],
                          tags: jishoSnapshot.data['data'][i]['tags'],
                          jlpt: jishoSnapshot.data['data'][i]['jlpt'],
                          word: jishoSnapshot.data['data'][i]['japanese'][0]
                              ['word'],
                          reading: jishoSnapshot.data['data'][i]['japanese'][0]
                              ['reading'],
                          senses: jishoSnapshot.data['data'][i]['senses'],
                          is_jmdict: jishoSnapshot.data['data'][i]
                              ['attribution']['jmdict'],
                          is_dbpedia: jishoSnapshot.data['data'][i]
                              ['attribution']['dbpedia'],
                          is_jmnedict: jishoSnapshot.data['data'][i]
                              ['attribution']['jmnedict']),
                      textEditingController: textEditingController,
                      hanViet: KanjiHelper.getHanvietReading(
                          word: vnDictQuery[index].word, context: context),
                      vnDefinition: vnDictQuery[index],
                    );
                  return searchResultTileFinished;
                } else
                  return searchResultTileOldWaiting;
              });
        },
      );
    } else
      return FutureBuilder(
        future: jishoData,
        builder: (context, jishoSnapshot) {
          if (jishoSnapshot.connectionState ==
              ConnectionState.done && jishoSnapshot.data != null){
            return ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      thickness: 0.4,
                    ),
                itemCount: jishoSnapshot.data["data"].length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder(
                    future: getVietnameseDefinition(jishoSnapshot.data['data'][index]['slug'] ?? jishoSnapshot.data['data'][index]['japanese'][0]
                    ['word']),
                      builder: (context, vnSnapshot){
                      if (vnSnapshot.connectionState == ConnectionState.done && vnSnapshot.data != null) {
                        return SearchResultTile(
                          jishoDefinition: JishoDefinition(
                              slug: jishoSnapshot.data['data'][index]['slug'],
                              is_common: jishoSnapshot.data['data'][index]
                              ['is_common'] ==
                                  null
                                  ? false
                                  : jishoSnapshot.data['data'][index]['is_common'],
                              tags: jishoSnapshot.data['data'][index]['tags'],
                              jlpt: jishoSnapshot.data['data'][index]['jlpt'],
                              word: jishoSnapshot.data['data'][index]['japanese'][0]
                              ['word'],
                              reading: jishoSnapshot.data['data'][index]['japanese']
                              [0]['reading'],
                              senses: jishoSnapshot.data['data'][index]['senses'],
                              is_jmdict: jishoSnapshot.data['data'][index]
                              ['attribution']['jmdict'],
                              is_dbpedia: jishoSnapshot.data['data'][index]
                              ['attribution']['dbpedia'],
                              is_jmnedict: jishoSnapshot.data['data'][index]
                              ['attribution']['jmnedict']),
                          textEditingController: textEditingController,
                          hanViet: KanjiHelper.getHanvietReading(
                              word: jishoSnapshot.data['data'][index]['japanese'][0]
                              ['word'] ??
                                  jishoSnapshot.data['data'][index]['slug'],
                              context: context),
                          vnDefinition: vnSnapshot.data,
                        );
                      } else return SearchResultTile(
                        jishoDefinition: JishoDefinition(
                            slug: jishoSnapshot.data['data'][index]['slug'],
                            is_common: jishoSnapshot.data['data'][index]
                            ['is_common'] ==
                                null
                                ? false
                                : jishoSnapshot.data['data'][index]['is_common'],
                            tags: jishoSnapshot.data['data'][index]['tags'],
                            jlpt: jishoSnapshot.data['data'][index]['jlpt'],
                            word: jishoSnapshot.data['data'][index]['japanese'][0]
                            ['word'],
                            reading: jishoSnapshot.data['data'][index]['japanese']
                            [0]['reading'],
                            senses: jishoSnapshot.data['data'][index]['senses'],
                            is_jmdict: jishoSnapshot.data['data'][index]
                            ['attribution']['jmdict'],
                            is_dbpedia: jishoSnapshot.data['data'][index]
                            ['attribution']['dbpedia'],
                            is_jmnedict: jishoSnapshot.data['data'][index]
                            ['attribution']['jmnedict']),
                        textEditingController: textEditingController,
                        hanViet: KanjiHelper.getHanvietReading(
                            word: jishoSnapshot.data['data'][index]['japanese'][0]
                            ['word'] ??
                                jishoSnapshot.data['data'][index]['slug'],
                            context: context),
                        vnDefinition:
                        VietnameseDefinition(word: null, definition: null),
                      );
                      });
                });}
          else
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            );
        },
      );
  }
}
