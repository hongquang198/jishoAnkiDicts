import 'package:flutter/material.dart';

import '../../../../models/grammar_point.dart';
import '../grammar_point_screen.dart';

class GrammarQueryTile extends StatefulWidget {
  final GrammarPoint grammarPoint;
  GrammarQueryTile({required this.grammarPoint});

  @override
  _GrammarQueryTileState createState() => _GrammarQueryTileState();
}

class _GrammarQueryTileState extends State<GrammarQueryTile> {
  @override
  void initState() {
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
                'HeroTag${widget.grammarPoint.grammarPoint}${widget.grammarPoint.jpSentence}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.grammarPoint.grammarPoint!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Card(
                color: Color(0xFF8ABC82),
                child: Text(
                  widget.grammarPoint.jlptLevel!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.grammarPoint.grammarMeaning!,
              style: TextStyle(fontSize: 13)),
        ],
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarPointScreen(
              grammarPoint: widget.grammarPoint,
            ),
          ),
        );
      },
    );
  }
}
