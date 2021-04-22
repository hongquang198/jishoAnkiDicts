import 'package:JapaneseOCR/utils/constants.dart';
import 'package:flutter/material.dart';

class DefinitionWidget extends StatelessWidget {
  String vietnameseDefinition;
  List<dynamic> english_definitions;
  DefinitionWidget({this.vietnameseDefinition, this.english_definitions});

  @override
  Widget build(BuildContext context) {
    String definition = '';
    for (int i = 0; i < english_definitions.length; i++) {
      definition = definition + english_definitions[i].toString();
      if (i != english_definitions.length - 1) {
        definition = definition + ', ';
      }
    }

    if (english_definitions.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            definition,
            style: TextStyle(fontSize: Constants.definitionTextSize),
          ),
          Text(
            vietnameseDefinition.replaceAll('\\n', '\n\n'),
            style: TextStyle(fontSize: Constants.definitionTextSize),
          ),
        ],
      );
    }
    return Text(
      'Unknown',
      style: TextStyle(fontSize: 20),
    );
  }
}
