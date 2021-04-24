import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'package:JapaneseOCR/services/jisho_query.dart';
import 'dart:async';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/widgets/nav_bar.dart';
import 'package:JapaneseOCR/widgets/search_result_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your history",
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
            List<OfflineWordRecord> history =
                Provider.of<Dictionary>(context).history;
            return SearchResultTile(
              textEditingController: widget.textEditingController,
              vietnameseDefinition: history[index].vietnamese_definition,
              jishoDefinition: JishoDefinition(
                slug: history[index].slug,
                is_common: history[index].is_common == 1 ? true : false,
                tags: convertToList(jsonDecode(history[index].tags).toString()),
                jlpt: convertToList(jsonDecode(history[index].jlpt).toString()),
                word: history[index].word,
                reading: history[index].reading,
                senses: jsonDecode(history[index].senses),
                is_jmdict: [],
                is_dbpedia: [],
                is_jmnedict: [],
              ),
            );
          },
        ),
      ),
    );
  }

// load kanji dictionary
}
