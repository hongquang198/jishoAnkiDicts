import 'package:jisho_anki/common/widgets/common_query_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/offline_word_record.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/kanji_helper.dart';
import '../../../utils/constants.dart';
import '../../../core/data/datasources/shared_pref.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late String clipboard;
  late List<OfflineWordRecord> history;

  @override
  void initState() {
    super.initState();
    history = getIt<Dictionary>()
        .history
        .reversed
        .toList();
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
            return getCommonQueryTile(index);
          },
        ),
      ),
    );
  }

  Widget getCommonQueryTile(int index) {
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
                    ),
                  jishoDefinition: history[index].toJishoDefinition,
                );
              else {
                return CommonQueryTile(
                  hanViet: KanjiHelper.getHanvietReading(
                      word: word,
                    ),
                  vnDefinition: snapshot.data,
                  jishoDefinition: history[index].toJishoDefinition,
                );
              }
            });
      } else
        return CommonQueryTile(
          hanViet: KanjiHelper.getHanvietReading(word: word),
          vnDefinition: VietnameseDefinition(
              word: word,
              definition: history[index].vietnameseDefinition),
          jishoDefinition: history[index].toJishoDefinition,
        );
    } else {
      return CommonQueryTile(
        hanViet: KanjiHelper.getHanvietReading(word: word),
        jishoDefinition: history[index].toJishoDefinition,
      );
    }
  }

// load kanji dictionary
}
