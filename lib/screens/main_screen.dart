import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/example_sentence.dart';
import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/services/jisho_query.dart';
import 'package:JapaneseOCR/services/kanjiHelper.dart';
import 'dart:async';
import 'package:JapaneseOCR/services/load_dictionary.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/widgets/nav_bar.dart';
import 'package:JapaneseOCR/widgets/search_result_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:JapaneseOCR/widgets/draw_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/services/recognizer.dart';
import 'package:flutter/services.dart';
import 'package:float_button_overlay/float_button_overlay.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String previousText;
  TextEditingController _textController;
  Timer searchOnStoppedTyping;
  Stream _stream;
  StreamController _streamController;

  JishoQuery jishoQuery = JishoQuery();
  var jishoData;
  final _recognizer = Recognizer();
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";

  Timer clipboardTriggerTime;
  String clipboard;

  _search() async {
    if (_textController.text == null || _textController.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add(null);

    _streamController.add("waiting");
    jishoData = await jishoQuery.getJishoQuery(_textController.text);
    _streamController.add(jishoData);
  }

  Future _initModel({String modelFilePath, String labelFilePath}) async {
    var res = await _recognizer.loadModel(
        modelPath: modelFilePath, labelPath: labelFilePath);
  }

  _onChangeHandler(value) async {
    const duration = Duration(
        milliseconds:
            150); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping = new Timer(duration, () async {
          await _search(); // Your state change code goes here
        }));
  }

  @override
  void initState() {
    _streamController = StreamController();
    _stream = _streamController.stream;
    _textController = TextEditingController();

    _textController.addListener(() async {
      if (previousText != _textController.text) {
        previousText = _textController.text;
        await _onChangeHandler(_textController.text);
      }
    });

    clipboardTriggerTime =
        Timer.periodic(const Duration(milliseconds: 75), (timer) {
      Clipboard.getData('text/plain').then((clipboardContent) {
        if (clipboard != clipboardContent.text) {
          clipboard = clipboardContent.text;
          _textController.text = clipboard;
        }
      });
    });
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String getVietnameseDefinition(String word) {
    VietnameseDefinition definition;
    try {
      definition = Provider.of<Dictionary>(context)
          .vietnameseDictionary
          .firstWhere((element) => element.word == word);
    } catch (e) {
      print(e);
    }
    return definition == null ? '' : definition.definition;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<Dictionary>(context) == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            drawer: NavBar(
              textEditingController: _textController,
            ),
            appBar: AppBar(
              title: Text(
                "Japanese Dictionary",
                style: TextStyle(color: Constants.appBarTextColor),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          style: TextStyle(color: Constants.appBarTextColor),
                          controller: _textController,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              icon: Icon(Icons.search),
                              color: Constants.appBarTextColor,
                              onPressed: () async {
                                await _search();
                              },
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Constants.appBarIconColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _textController.text = '';
                                });
                              },
                            ),
                            hintText: "Search for a word",
                            hintStyle:
                                TextStyle(color: Constants.appBarTextColor),
                            labelStyle:
                                TextStyle(color: Constants.appBarTextColor),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.only(bottom: 10),
                      icon: Icon(Icons.brush),
                      color: Constants.appBarIconColor,
                      onPressed: () {
                        setState(() {
                          _textController.text = '';
                        });
                        showModalBottomSheet(
                            isScrollControlled: true,
                            enableDrag: false,
                            context: context,
                            builder: (ctx) {
                              return Wrap(children: <Widget>[
                                Container(
                                  color: Color(0xFFf8f1f1),
                                  height: 400,
                                  child: DrawScreen(
                                      textEditingController: _textController),
                                ),
                              ]);
                            });
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              margin: EdgeInsets.all(8),
              child: StreamBuilder(
                stream: _stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Text("Enter a search word"),
                    );
                  }
                  if (snapshot.data == "waiting") {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      thickness: 0.4,
                    ),
                    itemCount: snapshot.data["data"].length,
                    itemBuilder: (BuildContext context, int index) {
                      return SearchResultTile(
                        textEditingController: _textController,
                        jishoDefinition: JishoDefinition(
                            slug: snapshot.data['data'][index]['slug'],
                            is_common: snapshot.data['data'][index]
                                        ['is_common'] ==
                                    null
                                ? false
                                : snapshot.data['data'][index]['is_common'],
                            tags: snapshot.data['data'][index]['tags'],
                            jlpt: snapshot.data['data'][index]['jlpt'],
                            word: snapshot.data['data'][index]['japanese'][0]
                                ['word'],
                            reading: snapshot.data['data'][index]['japanese'][0]
                                ['reading'],
                            senses: snapshot.data['data'][index]['senses'],
                            is_jmdict: snapshot.data['data'][index]
                                ['attribution']['jmdict'],
                            is_dbpedia: snapshot.data['data'][index]
                                ['attribution']['dbpedia'],
                            is_jmnedict: snapshot.data['data'][index]
                                ['attribution']['jmnedict']),
                      );
                    },
                  );
                },
              ),
            ),
          );
  }
}
