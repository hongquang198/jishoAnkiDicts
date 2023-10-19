import 'package:japanese_ocr/common/widgets/common_query_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/offline_word_record.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/kanji_helper.dart';
import '../../../utils/constants.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late String clipboard;

  Future<VietnameseDefinition> getVietnameseDefinition(String word) async {
    List<VietnameseDefinition> vnDefinition =
        await KanjiHelper.getVnDefinition(word: word);
    return vnDefinition[0];
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
                  if (snapshot.data == null)
                    return CommonQueryTile(
                      hanViet: KanjiHelper.getHanvietReading(
                          word: favorite[index].japaneseWord,
                        ),
                      vnDefinition: null,
                      jishoDefinition: favorite[index].toJishoDefinition,
                    );
                  return CommonQueryTile(
                    hanViet: KanjiHelper.getHanvietReading(
                        word: favorite[index].japaneseWord,
                      ),
                    vnDefinition: snapshot.data,
                    jishoDefinition: favorite[index].toJishoDefinition,
                  );
                });
          },
        ),
      ),
    );
  }

// load kanji dictionary
}
