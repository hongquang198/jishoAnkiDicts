import 'dart:convert';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/models/pitchAccent.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/services/dbHelper.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:JapaneseOCR/widgets/definition_screen/component_widget.dart';
import 'package:JapaneseOCR/widgets/definition_screen/definition_tags.dart';
import 'package:JapaneseOCR/widgets/definition_screen/example_sentence_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/widgets/definition_screen/definition_widget.dart';
import 'dart:async';

class DefinitionScreen extends StatefulWidget {
  final JishoDefinition jishoDefinition;
  final bool isInFavoriteList;
  final TextEditingController textEditingController;
  final bool isOfflineList;
  DefinitionScreen({
    this.textEditingController,
    this.jishoDefinition,
    this.isInFavoriteList,
    this.isOfflineList,
  });

  @override
  _DefinitionScreenState createState() => _DefinitionScreenState();
}

class _DefinitionScreenState extends State<DefinitionScreen> {
  bool isClipboardSet = false;
  String clipboard;
  Future<List<Widget>> pitchAccent;
  Future<List<String>> hanVietReading;
  Future<List<Kanji>> kanjiList;
  Future<String> vnDefinition;

  Widget getPartsOfSpeech(List<dynamic> partsOfSpeech) {
    if (partsOfSpeech.length > 0) {
      for (int i = 0; i < partsOfSpeech.length; i++) {
        return Text(
          partsOfSpeech[i].toString().toUpperCase(),
        );
      }
    }
    return SizedBox();
  }

  Future<String> getClipboard() async {
    ClipboardData data = await Clipboard.getData('text/plain');
    clipboard = data.text;
  }

  Widget addFlashcard() {
    //TODO
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    pitchAccent = KanjiHelper.getPitchAccent(
      word: widget.jishoDefinition.word,
      slug: widget.jishoDefinition.slug,
      reading: widget.jishoDefinition.reading,
      context: context,
    );

    hanVietReading = KanjiHelper.getHanvietReading(
        word: widget.jishoDefinition.word ??
            widget.jishoDefinition.slug ??
            widget.jishoDefinition.reading ??
            '',
        context: context);

    kanjiList = KanjiHelper.getKanjiComponent(
        word: widget.jishoDefinition.word ??
            widget.jishoDefinition.slug ??
            widget.jishoDefinition.reading ??
            '',
        context: context);

    vnDefinition = KanjiHelper.getVnDefinition(
        word: widget.jishoDefinition.word ??
            widget.jishoDefinition.slug ??
            widget.jishoDefinition.reading ??
            '',
        context: context);

    getClipboard();
    widget.textEditingController.addListener(() {
      if (mounted) {
        if (clipboard != widget.textEditingController.text) {
          clipboard = widget.textEditingController.text;
          Navigator.of(context).popUntil((route) => route.isFirst);
          print('Definition screen popped');
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Material(
            color: Colors.transparent,
            child: FutureBuilder(
              future: pitchAccent,
              builder: (context, snapshot) {
                if (snapshot.data == null)
                  return Text(
                    widget.jishoDefinition.reading ?? '',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey,
                    ),
                  );
                return Row(
                  children: snapshot.data,
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag:
                      'HeroTag${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      widget.jishoDefinition.word ??
                          widget.jishoDefinition.slug ??
                          widget.jishoDefinition.reading ??
                          '',
                      style: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Hero(
                tag:
                    'HeroTagBookmark${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
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
                            offlineWordRecord: OfflineWordRecord(
                              slug: widget.jishoDefinition.slug,
                              is_common:
                                  widget.jishoDefinition.is_common == true
                                      ? 1
                                      : 0,
                              tags: jsonEncode(widget.jishoDefinition.tags),
                              jlpt: jsonEncode(widget.jishoDefinition.jlpt),
                              word: widget.jishoDefinition.word,
                              reading: widget.jishoDefinition.reading,
                              senses: jsonEncode(widget.jishoDefinition.senses),
                              vietnamese_definition: null,
                              added: DateTime.now().microsecondsSinceEpoch,
                              firstReview: null,
                              lastReview: null,
                              due: null,
                              interval: null,
                              ease: 2.5,
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
          FutureBuilder(
            future: hanVietReading,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Text('');
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    snapshot.data.toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: snapshot.data.toString().toUpperCase()));
                      isClipboardSet = true;
                    },
                    child: isClipboardSet == false
                        ? Icon(Icons.copy)
                        : Icon(Icons.check_outlined),
                  ),
                ],
              );
            },
          ),
          Hero(
            tag:
                'HeroTagWordTags${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: Row(
              children: <Widget>[
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
          SizedBox(height: 8),
          DefinitionWidget(
            senses: widget.jishoDefinition.senses,
            vietnameseDefinition: vnDefinition,
          ),
          Divider(),
          Text(
            'Examples',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          ExampleSentenceWidget(
              word: widget.jishoDefinition.slug ?? widget.jishoDefinition.word),
          Divider(),
          Text(
            'Components',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          ComponentWidget(
            kanjiComponent: kanjiList,
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => addFlashcard(),
      ),
    );
  }
}
