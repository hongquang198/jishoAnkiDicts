import 'package:flutter/material.dart';
import 'definition_tags.dart';

class IsCommonTagsAndJlptWidget extends StatelessWidget {
  const IsCommonTagsAndJlptWidget({
    super.key,
    required this.isCommon,
    required this.tags,
    required this.jlpt,
  });

  final bool isCommon;
  final List<String> tags;
  final List<String> jlpt;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        if (isCommon)
          Card(
            color: Color(0xFF8ABC82),
            child: Text(
              'common word',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        DefinitionTags(
            tags: tags,
            color: Color(0xFF909DC0)),
        DefinitionTags(
            tags: jlpt,
            color: Color(0xFF909DC0)),
      ],
    );
  }
}
