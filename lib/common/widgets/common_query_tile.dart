import 'package:go_router/go_router.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:japanese_ocr/features/history/screens/saved_definition_screen.dart';

import '../../../../../common/widgets/custom_dialog.dart';
import '../../../../../config/app_routes.dart';
import '../../../../../injection.dart';
import '../../../../../models/offline_word_record.dart';
import '../../../../../models/vietnamese_definition.dart';
import '../../../../../core/data/datasources/shared_pref.dart';
import '../../../../../utils/offline_list_type.dart';
import '../../../../../services/db_helper.dart';
import '../../features/main_search/domain/entities/jisho_definition.dart';
import '../../features/word_definition/screens/widgets/definition_tags.dart';

class CommonQueryTile extends StatefulWidget {
  final JishoDefinition? jishoDefinition;
  final VietnameseDefinition? vnDefinition;
  final Future<List<String>> hanViet;
  final TextEditingController textEditingController;
  final bool loadingDefinition;

  CommonQueryTile({
    required this.hanViet,
    this.vnDefinition,
    this.jishoDefinition,
    required this.textEditingController,
    this.loadingDefinition = false,
  });

  @override
  _CommonQueryTileState createState() => _CommonQueryTileState();
}

class _CommonQueryTileState extends State<CommonQueryTile> {
  String get word {
    if (widget.vnDefinition?.word.isNotEmpty == true) {
      return widget.vnDefinition!.word;
    } else if (widget.jishoDefinition?.word?.isNotEmpty == true) {
      return widget.jishoDefinition!.word!;
    } else {
      return widget.jishoDefinition?.slug ?? '';
    }
  }

  parseVnDefHtmlWidget(String htmlString) {
    var document = parse(htmlString);
    var listList = document.querySelectorAll("li");

    for (dom.Element list in listList) {
      if (list.attributes["class"] == "nv_a") {
        return Text(
            list.text.length > 150 ? list.text.substring(0, 150) : list.text,
            style: TextStyle(fontSize: 12));
      }
    }
    return SizedBox();
  }

  getVnDefinitionSummary() {
    if (widget.vnDefinition?.definition == null) {
      return SizedBox();
    } else
      return parseVnDefHtmlWidget(widget.vnDefinition?.definition ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16.0, right: 0.0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.jishoDefinition?.reading != null
              ? Text(
                  widget.jishoDefinition?.reading ?? '',
                  style: TextStyle(fontSize: 13),
                )
              : SizedBox(),
          Text(
            word,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          getIt<SharedPref>().isAppInVietnamese
              ? FutureBuilder(
                  future: widget.hanViet,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data!.length == 0)
                      return SizedBox(height: 0);
                    return SelectableText(
                      snapshot.data.toString().toUpperCase(),
                      style: TextStyle(fontSize: 12),
                    );
                  },
                )
              : SizedBox(),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.loadingDefinition == true
              ? SizedBox(
                  width: 5,
                  height: 5,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ))
              : Row(
                  children: [
                    widget.jishoDefinition?.isCommon == true
                        ? Card(
                            color: Color(0xFF8ABC82),
                            child: Text(
                              'common word',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox(),
                    DefinitionTags(
                        tags: widget.jishoDefinition?.tags ?? [],
                        color: Color(0xFF909DC0)),
                    DefinitionTags(
                        tags: widget.jishoDefinition?.jlpt ?? [],
                        color: Color(0xFF909DC0)),
                  ],
                ),
          if (widget.jishoDefinition?.senses != null &&
              getIt<SharedPref>().isAppInEnglish)
            Text(
                widget.jishoDefinition!.senses[0].englishDefinitions
                        .toString(),
                style: TextStyle(fontSize: 13))
          else
            SizedBox(),
          getIt<SharedPref>().isAppInVietnamese
              ? getVnDefinitionSummary()
              : SizedBox(),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //state of word : bookmarked or not
          SizedBox(
            width: 45,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.favorite,
                      word: word,
                      context: context)
                  ? Icon(Icons.favorite, color: Color(0xffff8882))
                  : Icon(Icons.favorite, color: Colors.grey),
              onPressed: () {
                if (DbHelper.checkDatabaseExist(
                        offlineListType: OfflineListType.favorite,
                        word: word,
                        context: context) ==
                    false) {
                  setState(() {
                    DbHelper.addToOfflineList(
                        offlineListType: OfflineListType.favorite,
                        offlineWordRecord: OfflineWordRecord(
                          slug: word,
                          isCommon:
                              widget.jishoDefinition?.isCommon == true ? 1 : 0,
                          tags: widget.jishoDefinition?.tags ?? const [],
                          jlpt: widget.jishoDefinition?.jlpt ?? const [],
                          word: word,
                          reading: widget.jishoDefinition?.reading ?? '',
                          senses: widget.jishoDefinition?.senses ?? const [],
                          vietnameseDefinition: widget.vnDefinition?.definition ?? '',
                          added: DateTime.now().millisecondsSinceEpoch,
                          firstReview: null,
                          lastReview: null,
                          due: -1,
                          interval: 0,
                          ease: getIt<SharedPref>().prefs.getDouble('startingEase') ?? -1,
                          reviews: 0,
                          lapses: 0,
                          averageTimeMinute: 0,
                          totalTimeMinute: 0,
                          cardType: 'default',
                          noteType: 'default',
                          deck: 'default',
                        ),
                        context: context);
                  });
                } else
                  setState(() {
                    DbHelper.removeFromOfflineList(
                        offlineListType: OfflineListType.favorite,
                        context: context,
                        word: widget.jishoDefinition?.japaneseWord ?? '');
                  });
              },
            ),
          ),

          // Add button to review list
          SizedBox(
            width: 45,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.review,
                      word: word,
                      context: context)
                  ? Icon(Icons.alarm_on, color: Color(0xffff8882))
                  : Icon(Icons.alarm_add),
              onPressed: () {
                print(widget.vnDefinition?.word);
                if (DbHelper.checkDatabaseExist(
                        offlineListType: OfflineListType.review,
                        word: word,
                        context: context) ==
                    false) {
                  setState(() {
                    DbHelper.addToOfflineList(
                        offlineListType: OfflineListType.review,
                        offlineWordRecord: OfflineWordRecord(
                          slug: word,
                          isCommon:
                              widget.jishoDefinition?.isCommon == true ? 1 : 0,
                          tags: widget.jishoDefinition?.tags ?? const [],
                          jlpt: widget.jishoDefinition?.jlpt ?? const [],
                          word: word,
                          reading: widget.jishoDefinition?.reading ?? '',
                          senses: widget.jishoDefinition?.senses ?? const [],
                          vietnameseDefinition: widget.vnDefinition?.definition ?? '',
                          added: DateTime.now().millisecondsSinceEpoch,
                          firstReview: null,
                          lastReview: null,
                          due: -1,
                          interval: 0,
                          ease: getIt<SharedPref>().prefs.getDouble('startingEase') ?? -1,
                          reviews: 0,
                          lapses: 0,
                          averageTimeMinute: 0,
                          totalTimeMinute: 0,
                          cardType: 'default',
                          noteType: 'default',
                          deck: 'default',
                        ),
                        context: context);
                  });
                } else
                  setState(() {
                    DbHelper.removeFromOfflineList(
                        offlineListType: OfflineListType.review,
                        context: context,
                        word: word);
                  });
              },
            ),
          ),
        ],
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.pushNamed(
          AppRoutesPath.savedWordDefinition,
          extra: SavedDefinitionScreenArgs(
            hanViet: widget.hanViet,
            jishoDefinition: widget.jishoDefinition,
            vnDefinition: widget.vnDefinition,
            textEditingController: widget.textEditingController,
            isInFavoriteList: DbHelper.checkDatabaseExist(
                offlineListType: OfflineListType.favorite,
                word: word,
                context: context),
          ),
        );
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  word: word,
                  message: 'You are about to delete a word from history',
                ));
        setState(() {});
      },
    );
  }

}
