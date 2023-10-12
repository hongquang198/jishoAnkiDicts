import 'dart:convert';

import 'package:unofficial_jisho_api/api.dart';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/offlineWordRecord.dart';
import '../../../models/vietnameseDefinition.dart';
import '../../../services/kanjiHelper.dart';
import 'dart:async';
import '../../../utils/constants.dart';
import '../../../widgets/main_screen/search_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main_search/domain/entities/jisho_definition.dart';

class FavoriteScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  FavoriteScreen({required this.textEditingController});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late String clipboard;

  Future<String> getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    clipboard = data?.text ?? '';
    return clipboard;
  }

  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word);
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
          AppLocalizations.of(context)!.favorite,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            thickness: 0.4,
          ),
          itemCount: getIt<Dictionary>().favorite.length,
          itemBuilder: (BuildContext context, int index) {
            List<OfflineWordRecord> favorite =
                getIt<Dictionary>().favorite;
            favorite = favorite.reversed.toList();

            return FutureBuilder<VietnameseDefinition>(
                future: getVietnameseDefinition(
                    favorite[index].japaneseWord),
                builder: (context, snapshot) {
                  final senses = (jsonDecode(favorite[index].senses) as List)
                      .map((e) => JishoWordSense.fromJson(e))
                      .toList();
                  if (snapshot.data == null)
                    return SearchResultTile(
                      hanViet: KanjiHelper.getHanvietReading(
                          word: favorite[index].japaneseWord,
                          context: context),
                      vnDefinition: null,
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
                        senses: senses,
                        isJmdict: [],
                        isDbpedia: [],
                        isJmnedict: [],
                      ),
                    );
                  return SearchResultTile(
                    hanViet: KanjiHelper.getHanvietReading(
                        word: favorite[index].japaneseWord,
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
                      senses: senses,
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
