import 'dart:convert';

import '../../../models/dictionary.dart';
import '../../../models/jishoDefinition.dart';
import '../../../models/offlineWordRecord.dart';
import '../../../models/vietnameseDefinition.dart';
import '../../../services/kanjiHelper.dart';
import 'dart:async';
import '../../../utils/constants.dart';
import '../../../utils/sharedPref.dart';
import '../../../widgets/main_screen/search_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  HistoryScreen({this.textEditingController});
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String clipboard;
  Future<String> getClipboard() async {
    ClipboardData data = await Clipboard.getData('text/plain');
    clipboard = data.text;
    return data.text;
  }

  List<OfflineWordRecord> history;

  @override
  void initState() {
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
    history = Provider.of<Dictionary>(context, listen: false)
        .history
        .reversed
        .toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Convert normal String tags in offline dictionary to match list<dynamic> used by jisho api
  // Since List<dynamic> is processed to display word defintion
  List<String> convertToList(String string) {
    String bracketRemoved = string.substring(1, string.length - 1);
    List<String> stringSplitted;
    stringSplitted = bracketRemoved.split(', ');
    return stringSplitted;
  }

  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word, context: context);
    print(vnDefinition[0].word);
    return vnDefinition[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).history,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            thickness: 0.4,
          ),
          itemCount: Provider.of<Dictionary>(context).history.length,
          itemBuilder: (BuildContext context, int index) {
            return getSearchResultTile(index);
          },
        ),
      ),
    );
  }

  Widget getSearchResultTile(int index) {
    if (SharedPref.prefs.getString('language') == ('Tiếng Việt')) {
      if (history[index].vietnameseDefinition == null) {
        return FutureBuilder(
            future: getVietnameseDefinition(
                history[index].word ?? history[index].slug),
            builder: (context, snapshot) {
              if (snapshot.data == null)
                return SearchResultTile(
                  hanViet: KanjiHelper.getHanvietReading(
                      word: history[index].word ?? history[index].slug,
                      context: context),
                  vnDefinition:
                      VietnameseDefinition(word: null, definition: null),
                  textEditingController: widget.textEditingController,
                  jishoDefinition: JishoDefinition(
                    slug: history[index].slug,
                    isCommon: history[index].isCommon == 1 ? true : false,
                    tags: convertToList(
                        jsonDecode(history[index].tags).toString()),
                    jlpt: convertToList(
                        jsonDecode(history[index].jlpt).toString()),
                    word: history[index].word,
                    reading: history[index].reading,
                    senses: jsonDecode(history[index].senses),
                    isJmdict: [],
                    isDbpedia: [],
                    isJmnedict: [],
                  ),
                );
              else {
                return SearchResultTile(
                  hanViet: KanjiHelper.getHanvietReading(
                      word: history[index].word ?? history[index].slug,
                      context: context),
                  vnDefinition: snapshot.data,
                  textEditingController: widget.textEditingController,
                  jishoDefinition: JishoDefinition(
                    slug: history[index].slug,
                    isCommon: history[index].isCommon == 1 ? true : false,
                    tags: convertToList(
                        jsonDecode(history[index].tags).toString()),
                    jlpt: convertToList(
                        jsonDecode(history[index].jlpt).toString()),
                    word: history[index].word,
                    reading: history[index].reading,
                    senses: jsonDecode(history[index].senses),
                    isJmdict: [],
                    isDbpedia: [],
                    isJmnedict: [],
                  ),
                );
              }
            });
      } else
        return SearchResultTile(
          hanViet: KanjiHelper.getHanvietReading(
              word: history[index].word ?? history[index].slug,
              context: context),
          vnDefinition: VietnameseDefinition(
              word: history[index].word ?? history[index].slug,
              definition: history[index].vietnameseDefinition),
          textEditingController: widget.textEditingController,
          jishoDefinition: JishoDefinition(
            slug: history[index].slug,
            isCommon: history[index].isCommon == 1 ? true : false,
            tags: convertToList(jsonDecode(history[index].tags).toString()),
            jlpt: convertToList(jsonDecode(history[index].jlpt).toString()),
            word: history[index].word,
            reading: history[index].reading,
            senses: jsonDecode(history[index].senses),
            isJmdict: [],
            isDbpedia: [],
            isJmnedict: [],
          ),
        );
    } else
      return SearchResultTile(
        hanViet: KanjiHelper.getHanvietReading(
            word: history[index].word ?? history[index].slug, context: context),
        vnDefinition: VietnameseDefinition(word: null, definition: null),
        textEditingController: widget.textEditingController,
        jishoDefinition: JishoDefinition(
          slug: history[index].slug,
          isCommon: history[index].isCommon == 1 ? true : false,
          tags: convertToList(jsonDecode(history[index].tags).toString()),
          jlpt: convertToList(jsonDecode(history[index].jlpt).toString()),
          word: history[index].word,
          reading: history[index].reading,
          senses: jsonDecode(history[index].senses),
          isJmdict: [],
          isDbpedia: [],
          isJmnedict: [],
        ),
      );
  }

// load kanji dictionary
}
