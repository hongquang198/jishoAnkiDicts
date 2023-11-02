import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../../../../config/app_routes.dart';
import '../../../../../injection.dart';
import '../../../../../models/offline_word_record.dart';
import '../../../../../core/data/datasources/shared_pref.dart';
import '../../../../../utils/offline_list_type.dart';
import '../../../../../services/db_helper.dart';
import '../../../../word_definition/screens/definition_screen.dart';
import '../../../../word_definition/screens/widgets/is_common_tag_and_jlpt.dart';
import '../../../domain/entities/jisho_definition.dart';
import '../../bloc/main_search_bloc.dart';

class SearchResultTileEn extends StatefulWidget {
  final JishoDefinition? jishoDefinition;

  SearchResultTileEn({
    this.jishoDefinition,
  });

  @override
  _SearchResultTileEnState createState() => _SearchResultTileEnState();
}

class _SearchResultTileEnState extends State<SearchResultTileEn> {
  String get word {
    if (widget.jishoDefinition?.word?.isNotEmpty == true) {
      return widget.jishoDefinition!.word!;
    } else {
      return widget.jishoDefinition?.slug ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      contentPadding: EdgeInsets.only(left: 5, right: 3),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.jishoDefinition?.reading != null)
            Text(
              widget.jishoDefinition?.reading ?? '',
              style: TextStyle(fontSize: 11),
            ),
          Row(
            children: [
              Text(
                word,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0,),
            ],
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            children: [
              IsCommonTagsAndJlptWidget(
                      isCommon: widget.jishoDefinition?.isCommon == true,
                      tags: widget.jishoDefinition?.tags ?? [],
                      jlpt: widget.jishoDefinition?.jlpt ?? [],
                    ),
              if (widget.jishoDefinition?.senses != null)
                Text(
                    widget.jishoDefinition!.senses[0].englishDefinitions
                        .join(', '),
                    style: TextStyle(fontSize: 13))
            ],
          )
        ],
      ),
      trailing: SizedBox(
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
                      isCommon:
                          widget.jishoDefinition?.isCommon == true ? 1 : 0,
                      tags: widget.jishoDefinition?.tags ?? const [],
                      jlpt: widget.jishoDefinition?.jlpt ?? const [],
                      word: word,
                      reading: widget.jishoDefinition?.reading ?? '',
                      senses: widget.jishoDefinition?.senses ?? const [],
                      added: DateTime.now().millisecondsSinceEpoch,
                      firstReview: null,
                      lastReview: null,
                      due: -1,
                      interval: 0,
                      ease:
                          getIt<SharedPref>().prefs.getDouble('startingEase') ??
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.pushNamed(
          AppRoutesPath.wordDefinition,
          extra: DefinitionScreenArgs(
            mainSearchBloc: context.read<MainSearchBloc>(),
            jishoDefinition: widget.jishoDefinition,
            isInFavoriteList: DbHelper.checkDatabaseExist(
                        offlineListType: OfflineListType.favorite,
                        word: word,
                        context: context),
          ),
        );
      },
    );
  }

}
