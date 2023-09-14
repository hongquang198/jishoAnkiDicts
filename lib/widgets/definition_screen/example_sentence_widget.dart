import 'dart:convert';

import '/models/exampleSentence.dart';
import '/utils/constants.dart';
import 'package:flutter/material.dart';

class ExampleSentenceWidget extends StatefulWidget {
  final Future<List<ExampleSentence>> exampleSentence;

  ExampleSentenceWidget({required this.exampleSentence});
  @override
  _ExampleSentenceWidgetState createState() => _ExampleSentenceWidgetState();
}

class _ExampleSentenceWidgetState extends State<ExampleSentenceWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> generateSentence(List<ExampleSentence> exampleSentence) {
    List<Widget> sentence = [];

    for (int i = 0; i < exampleSentence.length; i++) {
      if (exampleSentence[i].jpSentence?.startsWith('[{"') == true) {
        var jsonList = jsonDecode(exampleSentence[i].jpSentence ?? '');
        for (int j = 0; j < jsonList.length; j++) {
          var jsonObject = jsonList[j];
          jsonObject.removeWhere((key, value) => value == null || value == '');
        }
        var prettyJsonString = JsonEncoder.withIndent('  ').convert(jsonList);
        exampleSentence[i].jpSentence = prettyJsonString
            .replaceAll('  ', "")
            .replaceAll("[\n", "")
            .replaceAll("]\n", "")
            .replaceAll("]", "");
      }
      if (i == 5) break;
      sentence.add(Padding(
        padding: EdgeInsets.only(right: 10, top: 9),
        child: Text(
          exampleSentence[i].jpSentence ?? '',
          style: TextStyle(
              fontSize: Constants.definitionTextSize,
              fontWeight: FontWeight.bold),
        ),
      ));
      if (exampleSentence[i].targetSentence != null)
        sentence.add(Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 2),
          child: Text(
            exampleSentence[i].targetSentence ?? '',
            style: TextStyle(fontSize: Constants.definitionTextSize),
          ),
        ));
    }
    return sentence;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExampleSentence>>(
        future: widget.exampleSentence,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            // print('Example dictionary is null');
            return SizedBox();
          }
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: generateSentence(snapshot.data ?? []));
        });
  }
}

// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: <Widget>[
// Text(
// '${snapshot.data[0].jpSentence}',
// style: TextStyle(
// fontSize: Constants.definitionTextSize,
// fontWeight: FontWeight.bold),
// ),
// Text(
// '${snapshot.data[0].vnSentence}',
// style: TextStyle(fontSize: Constants.definitionTextSize),
// ),
// Text(
// '${snapshot.data[1].jpSentence}',
// style: TextStyle(
// fontSize: Constants.definitionTextSize,
// fontWeight: FontWeight.bold),
// ),
// Text(
// '${snapshot.data[1].vnSentence}',
// style: TextStyle(fontSize: Constants.definitionTextSize),
// ),
// ],
// );
