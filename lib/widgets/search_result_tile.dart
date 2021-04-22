import 'package:flutter/material.dart';

class WordSearchResult extends StatefulWidget {
  String word;
  String definition;
  WordSearchResult(this.word, this.definition);

  @override
  _WordSearchResultState createState() => _WordSearchResultState();
}

class _WordSearchResultState extends State<WordSearchResult> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.word),
      trailing: FlatButton(
        child: isChecked
            ? Icon(Icons.bookmark, color: Color(0xffff8882))
            : Icon(Icons.bookmark, color: Colors.white),
        onPressed: () {
          if (isChecked = false)
            setState(() {
              isChecked = true;
            });
          else
            setState(() {
              isChecked = false;
            });
        },
      ),
    );
  }
}
