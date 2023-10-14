
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../injection.dart';
import '../core/domain/entities/dictionary.dart';
import '../models/offline_word_record.dart';
import '../utils/offline_list_type.dart';

class DbHelper {
  static bool checkDatabaseExist(
      {required OfflineListType offlineListType, required String word, required BuildContext context,}) {
    late List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.history) {
      table = getIt<Dictionary>().history;
    }
    else if (offlineListType == OfflineListType.favorite) {
      table = getIt<Dictionary>().favorite;
    }
    else if (offlineListType == OfflineListType.review) {
      table = getIt<Dictionary>().review;
    }
    return table.any((offlineWordRecord) => offlineWordRecord.japaneseWord == word);
  }

  // Remove from history or favorite
  static void removeFromOfflineList(
      {required OfflineListType offlineListType, required BuildContext context, required String word}) {
    List<OfflineWordRecord> table;
    if (offlineListType == OfflineListType.favorite) {
      table = getIt<Dictionary>().favorite;
      table.removeWhere((element) => element.japaneseWord == word);
      getIt<Dictionary>()
          .offlineDatabase
          .delete(word: word, tableName: 'favorite');
    } else if (offlineListType == OfflineListType.history) {
      table = getIt<Dictionary>().history;
      table.removeWhere((element) => element.japaneseWord == word);
      getIt<Dictionary>()
          .offlineDatabase
          .delete(word: word, tableName: 'history');
    } else if (offlineListType == OfflineListType.review) {
      table = getIt<Dictionary>().review;
      table.removeWhere((element) => element.japaneseWord == word);
      getIt<Dictionary>()
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
      if (!checkDatabaseExist(
              offlineListType: OfflineListType.history,
              word: offlineWordRecord.japaneseWord,
              context: context)) {
        getIt<Dictionary>()
            .history
            .add(offlineWordRecord);
        getIt<Dictionary>()
            .offlineDatabase
            .insertWord(
                offlineWordRecord: offlineWordRecord, tableName: 'history');
      } else {
        OfflineWordRecord found =
            getIt<Dictionary>().history.firstWhere(
                (element) =>
                    element.japaneseWord ==
                    offlineWordRecord.japaneseWord);
        found = found.copyWith(reviews: found.reviews+1);
        getIt<Dictionary>().history.remove(found);
        getIt<Dictionary>()
            .offlineDatabase
            .delete(word: found.japaneseWord, tableName: 'history');
        getIt<Dictionary>().history.add(found);
        getIt<Dictionary>()
            .offlineDatabase
            .insertWord(offlineWordRecord: found, tableName: 'history');
      }
    } else if (offlineListType == OfflineListType.favorite) {
      if (checkDatabaseExist(
              offlineListType: OfflineListType.favorite,
              word: offlineWordRecord.japaneseWord,
              context: context) ==
          false) {
        getIt<Dictionary>()
            .favorite
            .add(offlineWordRecord);
        getIt<Dictionary>()
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
        getIt<Dictionary>()
            .review
            .add(offlineWordRecord);
        getIt<Dictionary>()
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
      int index = getIt<Dictionary>()
          .review
          .indexWhere((element) =>
              (element.word.isEmpty ? element.slug : element.word) ==
              (offlineWordRecord.word.isEmpty ? offlineWordRecord.slug : offlineWordRecord.word));
      getIt<Dictionary>().review[index] =
          offlineWordRecord;
      getIt<Dictionary>()
          .offlineDatabase
          .update(offlineWordRecord: offlineWordRecord, tableName: 'review');
    }
  }
}
