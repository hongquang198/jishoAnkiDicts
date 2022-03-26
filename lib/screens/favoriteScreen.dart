import 'dart:convert';

import '../models/dictionary.dart';
import '../models/jishoDefinition.dart';
import '../models/offlineWordRecord.dart';
import '../models/vietnameseDefinition.dart';
import '../services/kanjiHelper.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../widgets/main_screen/search_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  FavoriteScreen({this.textEditingController});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  String clipboard;

  Future<String> getClipboard() async {
    ClipboardData data = await Clipboard.getData('text/plain');
    clipboard = data.text;
    return data.text;
  }

  getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word, context: context);
    return vnDefinition[0];
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Convert normal String tags in offline dictionary to match list<dynamic> used by jisho api
  // Since List<dynamic> is processed to display word defintion
  List<String> convertToList(String string) {
    if (string.length <= 1) return [string];
    String bracketRemoved = string.substring(1, string.length - 1);
    List<String> stringSplitted;
    stringSplitted = bracketRemoved.split(', ');
    return stringSplitted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).favorite,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            thickness: 0.4,
          ),
          itemCount: Provider.of<Dictionary>(context).favorite.length,
          itemBuilder: (BuildContext context, int index) {
            List<OfflineWordRecord> favorite =
                Provider.of<Dictionary>(context).favorite;
            favorite = favorite.reversed.toList();

            return FutureBuilder(
                future: getVietnameseDefinition(
                    favorite[index].word ?? favorite[index].slug),
                builder: (context, snapshot) {
                  if (snapshot.data == null)
                    return SearchResultTile(
                      hanViet: KanjiHelper.getHanvietReading(
                          word: favorite[index].word ?? favorite[index].slug,
                          context: context),
                      vnDefinition:
                          VietnameseDefinition(word: null, definition: null),
                      textEditingController: widget.textEditingController,
                      jishoDefinition: JishoDefinition(
                        slug: favorite[index].slug,
                        isCommon: favorite[index].isCommon == 1 ? true : false,
                        tags: convertToList(
                            jsonDecode(favorite[index].tags).toString()),
                        jlpt: convertToList(
                            jsonDecode(favorite[index].jlpt).toString()),
                        word: favorite[index].word,
                        reading: favorite[index].reading,
                        senses: jsonDecode(favorite[index].senses),
                        isJmdict: [],
                        isDbpedia: [],
                        isJmnedict: [],
                      ),
                    );
                  return SearchResultTile(
                    hanViet: KanjiHelper.getHanvietReading(
                        word: favorite[index].word ?? favorite[index].slug,
                        context: context),
                    vnDefinition: snapshot.data,
                    textEditingController: widget.textEditingController,
                    jishoDefinition: JishoDefinition(
                      slug: favorite[index].slug,
                      isCommon: favorite[index].isCommon == 1 ? true : false,
                      tags: convertToList(
                          jsonDecode(favorite[index].tags).toString()),
                      jlpt: convertToList(
                          jsonDecode(favorite[index].jlpt).toString()),
                      word: favorite[index].word,
                      reading: favorite[index].reading,
                      senses: jsonDecode(favorite[index].senses),
                      isJmdict: [],
                      isDbpedia: [],
                      isJmnedict: [],
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

// load kanji dictionary
}
