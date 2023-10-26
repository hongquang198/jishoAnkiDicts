import 'package:flutter/material.dart';
import 'package:jisho_anki/common/extensions/build_context_extension.dart';

import '../../../../models/grammar_point.dart';
import '../grammar_point_screen.dart';

class GrammarQueryTile extends StatefulWidget {
  final GrammarPoint grammarPoint;
  final bool showGrammarBadge;
  GrammarQueryTile({
    required this.grammarPoint,
    this.showGrammarBadge = false,
  });

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
      contentPadding: EdgeInsets.only(left: 5.0, right: 5),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag:
                'HeroTag${widget.grammarPoint.grammarPoint}${widget.grammarPoint.jpSentence}',
            child: Material(
              color: Colors.transparent,
              child: Text.rich(TextSpan(
                  text: widget.grammarPoint.grammarPoint!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: widget.showGrammarBadge
                          ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.collections_bookmark_outlined),
                          )
                          : const SizedBox.shrink(),
                    ),
                    TextSpan(
                      text: context.localizations.grammar,
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  ])
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
          if (widget.grammarPoint.grammarMeaning != null)
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
