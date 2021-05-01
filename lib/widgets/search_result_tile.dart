import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/screens/definition_screen.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:JapaneseOCR/services/dbHelper.dart';
import 'definition_screen/definition_tags.dart';

class SearchResultTile extends StatefulWidget {
  final JishoDefinition jishoDefinition;
  final String vietnameseDefinition;
  final TextEditingController textEditingController;
  SearchResultTile({
    this.jishoDefinition,
    this.textEditingController,
    this.vietnameseDefinition,
  });

  @override
  _SearchResultTileState createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  List<String> hanViet = [];
  List<Kanji> kanjiList = [];
  List<Kanji> kanjiDict;
  OfflineWordRecord offlineWordRecord;

  @override
  void initState() {
    kanjiDict = Provider.of<Dictionary>(context, listen: false).kanjiDictionary;
    hanViet = KanjiHelper.getHanvietReading(
        word: widget.jishoDefinition.word ??
            widget.jishoDefinition.slug ??
            widget.jishoDefinition.reading ??
            '',
        kanjiDict: kanjiDict);
    kanjiList = KanjiHelper.extractKanji(
        word: widget.jishoDefinition.word ??
            widget.jishoDefinition.slug ??
            widget.jishoDefinition.reading ??
            '',
        kanjiDict: kanjiDict);

    offlineWordRecord = OfflineWordRecord(
      slug: widget.jishoDefinition.slug,
      is_common: widget.jishoDefinition.is_common == true ? 1 : 0,
      tags: jsonEncode(widget.jishoDefinition.tags),
      jlpt: jsonEncode(widget.jishoDefinition.jlpt),
      word: widget.jishoDefinition.word,
      reading: widget.jishoDefinition.reading,
      senses: jsonEncode(widget.jishoDefinition.senses),
      vietnamese_definition: widget.vietnameseDefinition,
      added: DateTime.now().millisecondsSinceEpoch,
      firstReview: null,
      lastReview: null,
      due: null,
      interval: 0,
      ease: 2.5,
      reviews: 0,
      lapses: 0,
      averageTimeMinute: 0,
      totalTimeMinute: 0,
      cardType: 'default',
      noteType: 'default',
      deck: 'default',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16.0, right: 0.0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag:
                'HeroTagHiragana${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.jishoDefinition.reading ?? '',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
          Hero(
            tag:
                'HeroTag${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.jishoDefinition.word ??
                    '${widget.jishoDefinition.reading}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Hero(
            tag:
                'HeroTagHanViet${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                hanViet.toString().toUpperCase(),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Hero(
            tag:
                'HeroTagWordTags${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: Row(
              children: [
                widget.jishoDefinition.is_common == true
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
                    tags: widget.jishoDefinition.tags,
                    color: Color(0xFF909DC0)),
                DefinitionTags(
                    tags: widget.jishoDefinition.jlpt,
                    color: Color(0xFF909DC0)),
              ],
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              widget.jishoDefinition.senses[0]['english_definitions']
                      .toString() ??
                  'null',
              style: TextStyle(fontSize: 12)),
          // Todo: Adding vietnamese meaning
          // Text(
          //     widget.vietnameseDefinition.length > 150
          //         ? widget.vietnameseDefinition.substring(0, 150)
          //         : widget.vietnameseDefinition,
          //     style: TextStyle(fontSize: 12)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //state of word : bookmarked or not
          Hero(
            tag:
                'HeroTagBookmark${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: SizedBox(
              width: 45,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                child: DbHelper.checkDatabaseExist(
                        offlineListType: OfflineListType.favorite,
                        sense: widget.jishoDefinition.senses,
                        context: context)
                    ? Icon(Icons.bookmark, color: Color(0xffff8882))
                    : Icon(Icons.bookmark, color: Colors.grey),
                onPressed: () {
                  if (DbHelper.checkDatabaseExist(
                          offlineListType: OfflineListType.favorite,
                          sense: widget.jishoDefinition.senses,
                          context: context) ==
                      false) {
                    setState(() {
                      DbHelper.addToOfflineList(
                          offlineListType: OfflineListType.favorite,
                          offlineWordRecord: offlineWordRecord,
                          context: context);
                    });
                  } else
                    setState(() {
                      DbHelper.removeFromOfflineList(
                          offlineListType: OfflineListType.favorite,
                          senses: widget.jishoDefinition.senses,
                          context: context,
                          slug: widget.jishoDefinition.slug,
                          word: widget.jishoDefinition.word);
                    });
                },
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: DbHelper.checkDatabaseExist(
                      offlineListType: OfflineListType.review,
                      sense: widget.jishoDefinition.senses,
                      context: context)
                  ? Icon(Icons.verified, color: Color(0xffff8882))
                  : Icon(Icons.add, color: Color(0xff150e56)),
              onPressed: () {
                if (DbHelper.checkDatabaseExist(
                        offlineListType: OfflineListType.review,
                        sense: widget.jishoDefinition.senses,
                        context: context) ==
                    false) {
                  setState(() {
                    DbHelper.addToOfflineList(
                        offlineListType: OfflineListType.review,
                        offlineWordRecord: offlineWordRecord,
                        context: context);
                  });
                } else
                  setState(() {
                    DbHelper.removeFromOfflineList(
                        offlineListType: OfflineListType.review,
                        senses: widget.jishoDefinition.senses,
                        context: context,
                        slug: widget.jishoDefinition.slug,
                        word: widget.jishoDefinition.word);
                  });
              },
            ),
          ),
        ],
      ),
      onTap: () {
        FocusManager.instance.primaryFocus.unfocus();
        DbHelper.addToOfflineList(
            offlineListType: OfflineListType.history,
            offlineWordRecord: offlineWordRecord,
            context: context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DefinitionScreen(
              kanjiList: kanjiList,
              hanVietReading: hanViet,
              textEditingController: widget.textEditingController,
              isInFavoriteList: DbHelper.checkDatabaseExist(
                          offlineListType: OfflineListType.favorite,
                          sense: widget.jishoDefinition.senses,
                          context: context) ==
                      true
                  ? true
                  : false,
              jishoDefinition: widget.jishoDefinition,
              vietnameseDefinition: widget.vietnameseDefinition,
            ),
          ),
        );
      },
    );
  }
}
