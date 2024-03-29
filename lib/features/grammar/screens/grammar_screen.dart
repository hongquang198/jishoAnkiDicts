import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/grammar_point.dart';
import '../../../utils/constants.dart';
import '../../single_grammar_point/screen/widgets/grammar_query_tile.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});
  @override
  _GrammarScreenState createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  late TextEditingController _textController;
  late String clipboard;
  late List<GrammarPoint> grammarAll;
  Future<String> getClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    clipboard = data?.text ?? '';
    return clipboard;
  }

  _searchForGrammar(String grammarPoint) async {
    grammarAll = await getIt<Dictionary>()
        .offlineDatabase
        .searchForGrammar(grammarPoint: grammarPoint);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    grammarAll = getIt<Dictionary>().grammarDict;
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _textController.text = clipboard;
        _searchForGrammar(_textController.text);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.grammar,
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
                    onSubmitted: (valueChanged) {
                      _searchForGrammar(valueChanged);
                    },
                    style: TextStyle(color: Constants.appBarTextColor),
                    controller: _textController,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        color: Constants.appBarTextColor,
                        onPressed: () {},
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
                      hintText: "Search grammar point",
                      hintStyle: TextStyle(color: Constants.appBarTextColor),
                      labelStyle: TextStyle(color: Constants.appBarTextColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.only(bottom: 10),
                icon: Icon(Icons.paste_outlined),
                color: Constants.appBarIconColor,
                onPressed: () async {
                  await getClipboard();
                  _textController.text = clipboard;
                  _searchForGrammar(_textController.text);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            thickness: 0.4,
          ),
          itemCount: grammarAll.length,
          itemBuilder: (BuildContext context, int index) {
            return GrammarQueryTile(
              grammarPoint: grammarAll[index],
            );
          },
        ),
      ),
    );
  }

// load kanji dictionary
}
