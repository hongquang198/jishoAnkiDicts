import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'file:///C:/Users/ADMIN/AndroidStudioProjects/JapaneseOCR/lib/screens/definition_screen.dart';
import 'package:JapaneseOCR/services/dbManager.dart';
import 'package:JapaneseOCR/widgets/bookmark_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';

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

  bool checkDatabaseExist(OfflineListType type) {
    bool inDatabase = false;
    if (type == OfflineListType.history) {
      List<OfflineWordRecord> history =
          Provider.of<Dictionary>(context, listen: false).history;
      for (int i = 0; i < history.length; i++) {
        if (history[i].senses == jsonEncode(widget.jishoDefinition.senses)) {
          inDatabase = true;
        }
      }
    } else if (type == OfflineListType.favorite) {
      List<OfflineWordRecord> favorite =
          Provider.of<Dictionary>(context, listen: false).favorite;
      for (int i = 0; i < favorite.length; i++) {
        if (favorite[i].senses == jsonEncode(widget.jishoDefinition.senses)) {
          inDatabase = true;
        }
      }
    }
    return inDatabase;
  }

  // Remove from history or favorite
  void removeFromOfflineList() {
    List<OfflineWordRecord> favorite =
        Provider.of<Dictionary>(context, listen: false).favorite;
    favorite.removeWhere((element) =>
        element.senses == jsonEncode(widget.jishoDefinition.senses));
    Provider.of<Dictionary>(context, listen: false).offlineDatabase.delete(
        word: widget.jishoDefinition.slug ?? widget.jishoDefinition.word,
        tableName: 'favorite');
  }

  // Add to history or favorite
  void addToOfflineList(OfflineListType type) {
    OfflineWordRecord offlineWordRecord = OfflineWordRecord(
      slug: widget.jishoDefinition.slug,
      is_common: widget.jishoDefinition.is_common == true ? 1 : 0,
      tags: jsonEncode(widget.jishoDefinition.tags),
      jlpt: jsonEncode(widget.jishoDefinition.jlpt),
      word: widget.jishoDefinition.word,
      reading: widget.jishoDefinition.reading,
      senses: jsonEncode(widget.jishoDefinition.senses),
      vietnamese_definition: widget.vietnameseDefinition,
    );

    if (type == OfflineListType.history) {
      if (checkDatabaseExist(OfflineListType.history) == false) {
        Provider.of<Dictionary>(context, listen: false)
            .history
            .add(offlineWordRecord);
        Provider.of<Dictionary>(context, listen: false)
            .offlineDatabase
            .insertWord(
                offlineWordRecord: offlineWordRecord, tableName: 'history');
        print('Added to history list successfully');
      }
    } else if (type == OfflineListType.favorite) {
      if (checkDatabaseExist(OfflineListType.favorite) == false) {
        {
          Provider.of<Dictionary>(context, listen: false)
              .favorite
              .add(offlineWordRecord);
          Provider.of<Dictionary>(context, listen: false)
              .offlineDatabase
              .insertWord(
                  offlineWordRecord: offlineWordRecord, tableName: 'favorite');
          print('Added to favorite list successfully');
        }
      }
    }
  }

  // Extract kanji from word
  List<Kanji> extractKanji(String word) {
    List<Kanji> kanjiDict =
        Provider.of<Dictionary>(context, listen: false).kanjiDictionary;
    List<Kanji> kanjiExtracted = [];
    for (int i = 0; i < word.length; i++) {
      try {
        Kanji kanji =
            kanjiDict.firstWhere((element) => element.kanji == word[i]);
        if (kanji != null) {
          kanjiExtracted.add(kanji);
        }
      } catch (e) {
        print('Error extracting kanji $e');
      }
    }
    return kanjiExtracted;
  }

  List<String> getHanvietReading(String word) {
    List<String> array = [];
    List<Kanji> kanjiExtracted = extractKanji(word);
    for (int i = 0; i < kanjiExtracted.length; i++) {
      try {
        array = kanjiExtracted[i].hanViet.split(" ");
        hanViet.add(array[0].toUpperCase());
      } catch (e) {
        print('error adding kanji extracted $e');
      }
    }
    return hanViet;
  }

  @override
  void initState() {
    hanViet = getHanvietReading(widget.jishoDefinition.word ??
        widget.jishoDefinition.slug ??
        widget.jishoDefinition.reading ??
        '');
    kanjiList = extractKanji(widget.jishoDefinition.word ??
        widget.jishoDefinition.slug ??
        widget.jishoDefinition.reading ??
        '');
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
            child: BookmarkIcon(
              isInFavoriteList:
                  checkDatabaseExist(OfflineListType.favorite) == true
                      ? true
                      : false,
              addToOfflineList: addToOfflineList,
              removeFromOfflineList: removeFromOfflineList,
            ),
          ),
          SizedBox(
            width: 45,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Icon(Icons.add, color: Color(0xff150e56)),
              onPressed: () {},
            ),
          ),
        ],
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
        addToOfflineList(OfflineListType.history);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DefinitionScreen(
              kanjiList: kanjiList,
              hanVietReading: hanViet,
              textEditingController: widget.textEditingController,
              isInFavoriteList:
                  checkDatabaseExist(OfflineListType.favorite) == true
                      ? true
                      : false,
              addToOfflineList: addToOfflineList,
              removeFromOfflineList: removeFromOfflineList,
              jishoDefinition: widget.jishoDefinition,
              vietnameseDefinition: widget.vietnameseDefinition,
            ),
          ),
        );
      },
    );
  }
}
