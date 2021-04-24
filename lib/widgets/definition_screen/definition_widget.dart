import 'package:JapaneseOCR/utils/constants.dart';
import 'package:flutter/material.dart';

class DefinitionWidget extends StatelessWidget {
  String vietnameseDefinition;
  List<dynamic> senses;
  DefinitionWidget({this.vietnameseDefinition, this.senses});

  @override
  Widget build(BuildContext context) {
    String definition = '';
    for (int i = 0; i < senses.length; i++) {
      String definitionAtIndex = senses[i].toString();
      if (definitionAtIndex.length > 0) {
        definitionAtIndex =
            definitionAtIndex.substring(1, definitionAtIndex.length - 1);
        definition = definition + definitionAtIndex;
      }
      if (i != senses.length - 1) {
        definition = definition + '\n\n';
      }
    }

    if (senses.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < senses.length; i++) getDefinitions(i),
          // Text(
          //   vietnameseDefinition == null
          //       ? vietnameseDefinition.replaceAll('\\n', '\n\n')
          //       : '',
          //   style: TextStyle(fontSize: Constants.definitionTextSize),
          // ),
        ],
      );
    }
    return Text(
      'Unknown',
      style: TextStyle(fontSize: 20),
    );
  }

  Widget getDefinitions(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          senses[index]['parts_of_speech']
              .toString()
              .substring(
                  1, senses[index]['parts_of_speech'].toString().length - 1)
              .toUpperCase(),
          style: TextStyle(fontSize: 12),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, bottom: 10, top: 5),
          child: Text(
            senses[index]['english_definitions'].toString().substring(
                1, senses[index]['english_definitions'].toString().length - 1),
            style: TextStyle(
                fontSize: Constants.definitionTextSize,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
