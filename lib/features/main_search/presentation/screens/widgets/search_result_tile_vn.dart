import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../../../../../config/app_routes.dart';
import '../../../../../injection.dart';
import '../../../../../models/offline_word_record.dart';
import '../../../../../models/vietnamese_definition.dart';
import '../../../../../core/data/datasources/shared_pref.dart';
import '../../../../../utils/offline_list_type.dart';
import '../../../../../services/db_helper.dart';
import '../../../../word_definition/screens/definition_screen.dart';
import '../../../domain/entities/jisho_definition.dart';
import '../../bloc/main_search_bloc.dart';

class SearchResultTileVn extends StatefulWidget {
  final JishoDefinition? jishoDefinition;
  final VietnameseDefinition? vnDefinition;
  final List<String> hanViet;

  SearchResultTileVn({
    this.hanViet = const [],
    this.vnDefinition,
    this.jishoDefinition,
  });

  @override
  _SearchResultTileVnState createState() => _SearchResultTileVnState();
}

class _SearchResultTileVnState extends State<SearchResultTileVn> {
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
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.pushNamed(
          AppRoutesPath.wordDefinition,
          extra: DefinitionScreenArgs(
            mainSearchBloc: context.read<MainSearchBloc>(),
            hanViet: widget.hanViet,
            jishoDefinition: widget.jishoDefinition,
            vnDefinition: widget.vnDefinition,
            isInFavoriteList: DbHelper.checkDatabaseExist(
                offlineListType: OfflineListType.favorite,
                word: word,
                context: context),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.jishoDefinition?.reading != null)
                    Text(
                      widget.jishoDefinition?.reading ?? '',
                      style: TextStyle(fontSize: 11),
                    ),
                  if (widget.hanViet.length > 5)
                    SizedBox(
                      width: 150,
                      child: SelectableText(
                        widget.hanViet
                            .sublist(0, min(widget.hanViet.length, 4))
                            .join(' ')
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        word.substring(0, min(word.length, 12)),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                          ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      if (widget.hanViet.length <= 5)
                        SizedBox(
                          width: 150,
                          child: SelectableText(
                            widget.hanViet.join(' ').toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                  Wrap(
                    children: [getVnDefinitionSummary()],
                  )
                ],
              ),
            ),
            SizedBox(
              width: 35,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: DbHelper.checkDatabaseExist(
                        offlineListType: OfflineListType.favorite,
                        word: word,
                        context: context)
                    ? Icon(Icons.bookmark, color: Color(0xffff8882))
                    : Icon(Icons.bookmark, color: Colors.grey),
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
                            isCommon: widget.jishoDefinition?.isCommon == true
                                ? 1
                                : 0,
                            tags: widget.jishoDefinition?.tags ?? const [],
                            jlpt: widget.jishoDefinition?.jlpt ?? const [],
                            word: word,
                            reading: widget.jishoDefinition?.reading ?? '',
                            senses: widget.jishoDefinition?.senses ?? const [],
                            vietnameseDefinition:
                                widget.vnDefinition?.definition ?? '',
                            added: DateTime.now().millisecondsSinceEpoch,
                            firstReview: null,
                            lastReview: null,
                            due: -1,
                            interval: 0,
                            ease: getIt<SharedPref>()
                                    .prefs
                                    .getDouble('startingEase') ??
                                -1,
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
          ],
        ),
      ),
    );
  }

}
