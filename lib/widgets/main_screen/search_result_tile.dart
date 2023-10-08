import 'dart:convert';
import '/widgets/customDialog.dart';
import '/models/offlineWordRecord.dart';
import '/models/jishoDefinition.dart';
import '/models/vietnameseDefinition.dart';
import '../../features/word_definition/screens/definition_screen.dart';
import '../../core/data/datasources/sharedPref.dart';
import 'package:flutter/material.dart';
import '/utils/offlineListType.dart';
import '/services/dbHelper.dart';
import '../definition_screen/definition_tags.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

class SearchResultTile extends StatefulWidget {
  final JishoDefinition? jishoDefinition;
  final VietnameseDefinition? vnDefinition;
  final Future<List<String>> hanViet;
  final TextEditingController textEditingController;
  final bool loadingDefinition;

  SearchResultTile(
      {required this.hanViet,
      this.vnDefinition = const VietnameseDefinition(),
      this.jishoDefinition = const JishoDefinition(),
      required this.textEditingController,
      this.loadingDefinition = false});

  @override
  _SearchResultTileState createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  String get word {
    if (widget.vnDefinition?.word.isNotEmpty == true) {
      return widget.vnDefinition!.word;
    } else if (widget.jishoDefinition?.word?.isNotEmpty == true) {
      return widget.jishoDefinition!.word!;
    } else {
      return widget.jishoDefinition?.slug ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => DefinitionScreen(
        args: DefinitionScreenArgs(
          hanViet: widget.hanViet,
          vnDefinition: widget.vnDefinition,
          textEditingController: widget.textEditingController,
          isInFavoriteList: DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.favorite,
                      word: word,
                      context: context) ==
                  true
              ? true
              : false,
          jishoDefinition: widget.jishoDefinition,
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.decelerate;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
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
          SharedPref.prefs.getString('language') == ("Tiếng Việt")
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
              SharedPref.prefs.getString('language') == ("English"))
            Text(
                widget.jishoDefinition!.senses[0]['english_definitions']
                        .toString(),
                style: TextStyle(fontSize: 13))
          else
            SizedBox(),
          SharedPref.prefs.getString('language') == ("Tiếng Việt")
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
                          tags: jsonEncode(widget.jishoDefinition?.tags),
                          jlpt: jsonEncode(widget.jishoDefinition?.jlpt),
                          word: word,
                          reading: widget.jishoDefinition?.reading ?? '',
                          senses: jsonEncode(widget.jishoDefinition?.senses),
                          vietnameseDefinition: widget.vnDefinition?.definition ?? '',
                          added: DateTime.now().millisecondsSinceEpoch,
                          firstReview: null,
                          lastReview: null,
                          due: -1,
                          interval: 0,
                          ease: SharedPref.prefs.getDouble('startingEase') ?? -1,
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
                          tags: jsonEncode(widget.jishoDefinition?.tags),
                          jlpt: jsonEncode(widget.jishoDefinition?.jlpt),
                          word: word,
                          reading: widget.jishoDefinition?.reading ?? '',
                          senses: jsonEncode(widget.jishoDefinition?.senses),
                          vietnameseDefinition: widget.vnDefinition?.definition ?? '',
                          added: DateTime.now().millisecondsSinceEpoch,
                          firstReview: null,
                          lastReview: null,
                          due: -1,
                          interval: 0,
                          ease: SharedPref.prefs.getDouble('startingEase') ?? -1,
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
        DbHelper.addToOfflineList(
            offlineListType: OfflineListType.history,
            offlineWordRecord: OfflineWordRecord(
              slug: word,
              isCommon: widget.jishoDefinition?.isCommon == true ? 1 : 0,
              tags: jsonEncode(widget.jishoDefinition?.tags),
              jlpt: jsonEncode(widget.jishoDefinition?.jlpt),
              word: word,
              reading: widget.jishoDefinition?.reading ?? '',
              senses: jsonEncode(widget.jishoDefinition?.senses),
              vietnameseDefinition: widget.vnDefinition?.definition ?? '',
              added: DateTime.now().millisecondsSinceEpoch,
              firstReview: null,
              lastReview: null,
              due: -1,
              interval: 0,
              ease: SharedPref.prefs.getDouble('startingEase') ?? -1,
              reviews: 0,
              lapses: 0,
              averageTimeMinute: 0,
              totalTimeMinute: 0,
              cardType: 'default',
              noteType: 'default',
              deck: 'default',
            ),
            context: context);
        Navigator.of(context).push(_createRoute());
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
