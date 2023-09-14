
import '../models/dictionary.dart';
import '../models/offlineWordRecord.dart';
import '../utils/offlineListType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DbHelper {
  static bool checkDatabaseExist(
      {required OfflineListType offlineListType, required String word, required BuildContext context,}) {
    late List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.history)
      table = Provider.of<Dictionary>(context, listen: false).history;
    else if (offlineListType == OfflineListType.favorite)
      table = Provider.of<Dictionary>(context, listen: false).favorite;
    else if (offlineListType == OfflineListType.review)
      table = Provider.of<Dictionary>(context, listen: false).review;
    bool inDatabase = false;
    for (int i = 0; i < table.length; i++) {
      String tableWord = table[i].word;
      if (tableWord.isEmpty) {
        tableWord = table[i].slug;
      }
      if (tableWord == word) {
        inDatabase = true;
      }
    }
    return inDatabase;
  }

  // Remove from history or favorite
  static void removeFromOfflineList(
      {required OfflineListType offlineListType, required BuildContext context, required String word}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.favorite) {
      table = Provider.of<Dictionary>(context, listen: false).favorite;
      table.removeWhere((element) => element.japaneseWord == word);
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: word, tableName: 'favorite');
    } else if (offlineListType == OfflineListType.history) {
      table = Provider.of<Dictionary>(context, listen: false).history;
      table.removeWhere((element) => element.japaneseWord == word);
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: word, tableName: 'history');
    } else if (offlineListType == OfflineListType.review) {
      table = Provider.of<Dictionary>(context, listen: false).review;
      table.removeWhere((element) => element.japaneseWord == word);
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: word, tableName: 'review');
    }
  }

  // Add to history or favorite
  static void addToOfflineList(
      {required OfflineListType offlineListType,
      required OfflineWordRecord offlineWordRecord,
      required BuildContext context}) {
    if (offlineListType == OfflineListType.history) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.history,
              word: offlineWordRecord.japaneseWord,
              context: context) ==
          false) {
        Provider.of<Dictionary>(context, listen: false)
            .history
            .add(offlineWordRecord);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(
                offlineWordRecord: offlineWordRecord, tableName: 'history');
      } else {
        OfflineWordRecord found =
            Provider.of<Dictionary>(context, listen: false).history.firstWhere(
                (element) =>
                    element.japaneseWord ==
                    offlineWordRecord.japaneseWord);
        found.reviews++;
        Provider.of<Dictionary>(context, listen: false).history.remove(found);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .delete(word: found.japaneseWord, tableName: 'history');
        Provider.of<Dictionary>(context, listen: false).history.add(found);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(offlineWordRecord: found, tableName: 'history');
      }
    } else if (offlineListType == OfflineListType.favorite) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.favorite,
              word: offlineWordRecord.japaneseWord,
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
              word: offlineWordRecord.japaneseWord,
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

  static void updateWordInfo({
    required OfflineListType offlineListType,
    required BuildContext context,
    required OfflineWordRecord offlineWordRecord,
  }) {
    if (offlineListType == OfflineListType.review) {
      int index = Provider.of<Dictionary>(context, listen: false)
          .review
          .indexWhere((element) =>
              (element.word.isEmpty ? element.slug : element.word) ==
              (offlineWordRecord.word.isEmpty ? offlineWordRecord.slug : offlineWordRecord.word));
      Provider.of<Dictionary>(context, listen: false).review[index] =
          offlineWordRecord;
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .update(offlineWordRecord: offlineWordRecord, tableName: 'review');
    }
  }
}
