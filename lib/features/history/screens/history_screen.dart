import 'package:japanese_ocr/common/widgets/common_query_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/offline_word_record.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/kanji_helper.dart';
import '../../../utils/constants.dart';
import '../../../core/data/datasources/shared_pref.dart';
import '../../main_search/domain/entities/jisho_definition.dart';

class HistoryScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  HistoryScreen({required this.textEditingController});
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late String clipboard;
  Future<String> getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    clipboard = data?.text ?? '';
    return clipboard;
  }

  late List<OfflineWordRecord> history;

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
    history = getIt<Dictionary>()
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
        await KanjiHelper.getVnDefinition(word: word);
    print(vnDefinition[0].word);
    return vnDefinition[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.history,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            thickness: 0.4,
          ),
          itemCount: getIt<Dictionary>().history.length,
          itemBuilder: (BuildContext context, int index) {
            return getSearchResultTile(index);
          },
        ),
      ),
    );
  }

  Widget getSearchResultTile(int index) {
    final senses = history[index].senses;
    final offlineWordRecord = history[index];
    final word = offlineWordRecord.word.isEmpty
        ? offlineWordRecord.slug
        : offlineWordRecord.word;
    if (getIt<SharedPref>().isAppInVietnamese) {
      if (history[index].vietnameseDefinition.isEmpty) {
        return FutureBuilder<VietnameseDefinition>(
            future: getVietnameseDefinition(word),
            builder: (context, snapshot) {
              if (snapshot.data == null)
                return CommonQueryTile(
                  hanViet: KanjiHelper.getHanvietReading(
                      word: word,
                      context: context),
                  textEditingController: widget.textEditingController,
                  jishoDefinition: JishoDefinition(
                    slug: history[index].slug,
                    isCommon: history[index].isCommon == 1 ? true : false,
                    tags: history[index].tags,
                    jlpt: history[index].jlpt,
                    word: history[index].word,
                    reading: history[index].reading,
                    senses: senses,
                    isJmdict: [],
                    isDbpedia: [],
                    isJmnedict: [],
                  ),
                );
              else {
                return CommonQueryTile(
                  hanViet: KanjiHelper.getHanvietReading(
                      word: word,
                      context: context),
                  vnDefinition: snapshot.data,
                  textEditingController: widget.textEditingController,
                  jishoDefinition: JishoDefinition(
                    slug: history[index].slug,
                    isCommon: history[index].isCommon == 1 ? true : false,
                    tags: history[index].tags,
                    jlpt: history[index].jlpt,
                    word: history[index].word,
                    reading: history[index].reading,
                    senses: senses,
                    isJmdict: [],
                    isDbpedia: [],
                    isJmnedict: [],
                  ),
                );
              }
            });
      } else
        return CommonQueryTile(
          hanViet: KanjiHelper.getHanvietReading(
              word: word,
              context: context),
          vnDefinition: VietnameseDefinition(
              word: word,
              definition: history[index].vietnameseDefinition),
          textEditingController: widget.textEditingController,
          jishoDefinition: JishoDefinition(
            slug: history[index].slug,
            isCommon: history[index].isCommon == 1 ? true : false,
            tags: history[index].tags,
            jlpt: history[index].jlpt,
            word: history[index].word,
            reading: history[index].reading,
            senses: senses,
            isJmdict: [],
            isDbpedia: [],
            isJmnedict: [],
          ),
        );
    } else {
      return CommonQueryTile(
        hanViet: KanjiHelper.getHanvietReading(
            word: word, context: context),
        textEditingController: widget.textEditingController,
        jishoDefinition: JishoDefinition(
          slug: history[index].slug,
          isCommon: history[index].isCommon == 1 ? true : false,
          tags: history[index].tags,
          jlpt: history[index].jlpt,
          word: history[index].word,
          reading: history[index].reading,
          senses: senses,
          isJmdict: [],
          isDbpedia: [],
          isJmnedict: [],
        ),
      );
    }
  }

// load kanji dictionary
}
