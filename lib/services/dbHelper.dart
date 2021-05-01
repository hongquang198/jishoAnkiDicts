import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class DbHelper {
  static bool checkDatabaseExist(
      {OfflineListType offlineListType,
      List<dynamic> sense,
      BuildContext context}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.history)
      table = Provider.of<Dictionary>(context, listen: false).history;
    else if (offlineListType == OfflineListType.favorite)
      table = Provider.of<Dictionary>(context, listen: false).favorite;
    else if (offlineListType == OfflineListType.review)
      table = Provider.of<Dictionary>(context, listen: false).review;
    bool inDatabase = false;
    for (int i = 0; i < table.length; i++) {
      if (table[i].senses == jsonEncode(sense)) {
        inDatabase = true;
      }
    }
    return inDatabase;
  }

  // Remove from history or favorite
  static void removeFromOfflineList(
      {OfflineListType offlineListType,
      List<dynamic> senses,
      BuildContext context,
      String slug,
      String word}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.favorite) {
      table = Provider.of<Dictionary>(context, listen: false).favorite;
      table.removeWhere((element) => element.senses == jsonEncode(senses));
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: slug ?? word, tableName: 'favorite');
    } else if (offlineListType == OfflineListType.history) {
      table = Provider.of<Dictionary>(context, listen: false).history;
      table.removeWhere((element) => element.senses == jsonEncode(senses));
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: slug ?? word, tableName: 'history');
    } else if (offlineListType == OfflineListType.review) {
      table = Provider.of<Dictionary>(context, listen: false).review;
      table.removeWhere((element) => element.senses == jsonEncode(senses));
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: slug ?? word, tableName: 'review');
    }
  }

  // Add to history or favorite
  static void addToOfflineList(
      {OfflineListType offlineListType,
      OfflineWordRecord offlineWordRecord,
      BuildContext context}) {
    if (offlineListType == OfflineListType.history) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.history,
              sense: jsonDecode(offlineWordRecord.senses),
              context: context) ==
          false) {
        Provider.of<Dictionary>(context, listen: false)
            .history
            .add(offlineWordRecord);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(
                offlineWordRecord: offlineWordRecord, tableName: 'history');
        print('Added to history list successfully');
      }
    } else if (offlineListType == OfflineListType.favorite) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.favorite,
              sense: jsonDecode(offlineWordRecord.senses),
              context: context) ==
          false) {
        Provider.of<Dictionary>(context, listen: false)
            .favorite
            .add(offlineWordRecord);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(
                offlineWordRecord: offlineWordRecord, tableName: 'favorite');
        print('Added to favorite list successfully');
      }
    } else if (offlineListType == OfflineListType.review) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.review,
              sense: jsonDecode(offlineWordRecord.senses),
              context: context) ==
          false) {
        Provider.of<Dictionary>(context, listen: false)
            .review
            .add(offlineWordRecord);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(
                offlineWordRecord: offlineWordRecord, tableName: 'review');
        print('Added to review list successfully');
      }
    }
  }

  static void updateWordInfo(
      {OfflineListType offlineListType,
      List<dynamic> senses,
      BuildContext context,
      OfflineWordRecord offlineWordRecord}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.review) {
      table = Provider.of<Dictionary>(context, listen: false).review;
      int index =
          table.indexWhere((element) => element.senses == jsonEncode(senses));
      table[index] = offlineWordRecord;
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .update(offlineWordRecord: offlineWordRecord, tableName: 'review');
    }
  }
}

// OfflineWordRecord offlineWordRecord = OfflineWordRecord(
//   slug: widget.jishoDefinition.slug,
//   is_common: widget.jishoDefinition.is_common == true ? 1 : 0,
//   tags: jsonEncode(widget.jishoDefinition.tags),
//   jlpt: jsonEncode(widget.jishoDefinition.jlpt),
//   word: widget.jishoDefinition.word,
//   reading: widget.jishoDefinition.reading,
//   senses: jsonEncode(widget.jishoDefinition.senses),
//   vietnamese_definition: widget.vietnameseDefinition,
//   added: DateTime.now().microsecondsSinceEpoch,
//   firstReview: null,
//   lastReview: null,
//   due: null,
//   interval: null,
//   ease: 2.5,
//   reviews: 0,
//   lapses: 0,
//   averageTimeMinute: 0,
//   totalTimeMinute: 0,
//   cardType: 'default',
//   noteType: 'default',
//   deck: 'default',
// );
