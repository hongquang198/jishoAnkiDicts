
import '../models/dictionary.dart';
import '../models/offlineWordRecord.dart';
import '../utils/offlineListType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DbHelper {
  static bool checkDatabaseExist(
      {OfflineListType offlineListType, String word, BuildContext context}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.history)
      table = Provider.of<Dictionary>(context, listen: false).history;
    else if (offlineListType == OfflineListType.favorite)
      table = Provider.of<Dictionary>(context, listen: false).favorite;
    else if (offlineListType == OfflineListType.review)
      table = Provider.of<Dictionary>(context, listen: false).review;
    bool inDatabase = false;
    for (int i = 0; i < table.length; i++) {
      if ((table[i].word ?? table[i].slug) == word) {
        inDatabase = true;
      }
    }
    return inDatabase;
  }

  // Remove from history or favorite
  static void removeFromOfflineList(
      {OfflineListType offlineListType, BuildContext context, String word}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.favorite) {
      table = Provider.of<Dictionary>(context, listen: false).favorite;
      table.removeWhere((element) => (element.word ?? element.slug) == word);
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: word, tableName: 'favorite');
    } else if (offlineListType == OfflineListType.history) {
      table = Provider.of<Dictionary>(context, listen: false).history;
      table.removeWhere((element) => (element.word ?? element.slug) == word);
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: word, tableName: 'history');
    } else if (offlineListType == OfflineListType.review) {
      table = Provider.of<Dictionary>(context, listen: false).review;
      table.removeWhere((element) => (element.word ?? element.slug) == word);
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .delete(word: word, tableName: 'review');
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
              word: offlineWordRecord.word ?? offlineWordRecord.slug,
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
                    (element.word ?? element.slug) ==
                    (offlineWordRecord.word ?? offlineWordRecord.slug));
        found.reviews++;
        Provider.of<Dictionary>(context, listen: false).history.remove(found);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .delete(word: found.word ?? found.slug, tableName: 'history');
        Provider.of<Dictionary>(context, listen: false).history.add(found);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(offlineWordRecord: found, tableName: 'history');
      }
    } else if (offlineListType == OfflineListType.favorite) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.favorite,
              word: offlineWordRecord.word ?? offlineWordRecord.slug,
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
              word: offlineWordRecord.word ?? offlineWordRecord.slug,
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
    OfflineListType offlineListType,
    List<dynamic> senses,
    BuildContext context,
    OfflineWordRecord offlineWordRecord,
  }) {
    if (offlineListType == OfflineListType.review) {
      int index = Provider.of<Dictionary>(context, listen: false)
          .review
          .indexWhere((element) =>
              (element.word ?? element.slug) ==
              (offlineWordRecord.word ?? offlineWordRecord.slug));
      Provider.of<Dictionary>(context, listen: false).review[index] =
          offlineWordRecord;
      Provider.of<Dictionary>(context, listen: false)
          .offlineDatabase
          .update(offlineWordRecord: offlineWordRecord, tableName: 'review');
    }
  }
}
