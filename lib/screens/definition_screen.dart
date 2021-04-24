import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/widgets/bookmark_icon.dart';
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
  final String vietnameseDefinition;
  final bool isInFavoriteList;
  final Function addToOfflineList;
  final Function removeFromOfflineList;
  final TextEditingController textEditingController;
  final bool isOfflineList;
  final List<String> hanVietReading;
  final List<Kanji> kanjiList;
  DefinitionScreen({
    this.textEditingController,
    this.jishoDefinition,
    this.vietnameseDefinition,
    this.removeFromOfflineList,
    this.addToOfflineList,
    this.isInFavoriteList,
    this.isOfflineList,
    this.hanVietReading,
    this.kanjiList,
  });

  @override
  _DefinitionScreenState createState() => _DefinitionScreenState();
}

class _DefinitionScreenState extends State<DefinitionScreen>
    with AutomaticKeepAliveClientMixin<DefinitionScreen> {
  String clipboard;
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

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
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
                child: BookmarkIcon(
                  isInFavoriteList: widget.isInFavoriteList,
                  addToOfflineList: widget.addToOfflineList,
                  removeFromOfflineList: widget.removeFromOfflineList,
                ),
              ),
            ],
          ),
          Hero(
            tag:
                'HeroTagHiragana${widget.jishoDefinition.word}${widget.jishoDefinition.reading}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.jishoDefinition.reading ?? '',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey,
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
                widget.hanVietReading.toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
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
            vietnameseDefinition: widget.vietnameseDefinition,
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
            kanjiList: widget.kanjiList,
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
