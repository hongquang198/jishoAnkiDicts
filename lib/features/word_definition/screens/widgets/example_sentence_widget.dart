// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../common/widgets/common_animated_list_item.dart';
import '../../../../models/example_sentence.dart';
import '/utils/constants.dart';

class ExampleSentenceWidget extends StatelessWidget {
  final Future<List<ExampleSentence>> exampleSentence;
  const ExampleSentenceWidget({
    super.key,
    required this.exampleSentence,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExampleSentence>>(
        future: exampleSentence,
        builder: (context, snapshot) {
          if (snapshot.data == null ||
              snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          return _ExampleSentenceWidget(
            key: key,
            exampleSentences: snapshot.data!,
          );
        });
  }
}

class _ExampleSentenceWidget extends StatefulWidget {
  final List<ExampleSentence> exampleSentences;
  const _ExampleSentenceWidget({
    super.key,
    required this.exampleSentences,
  });

  @override
  State<_ExampleSentenceWidget> createState() => __ExampleSentenceWidgetState();
}

class __ExampleSentenceWidgetState extends State<_ExampleSentenceWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.exampleSentences.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: generateSentence(widget.exampleSentences),
    );
  }

  List<Widget> generateSentence(List<ExampleSentence> exampleSentence) {
    List<Widget> sentence = [];

    for (int i = 0; i < exampleSentence.length; i++) {
      var jpSentence = exampleSentence[i].jpSentence ?? '';
      if (jpSentence.startsWith('[{"')) {
        var jsonList = jsonDecode(jpSentence);
        for (int j = 0; j < jsonList.length; j++) {
          var jsonObject = jsonList[j];
          jsonObject.removeWhere((key, value) => value == null || value == '');
        }
        var prettyJsonString = JsonEncoder.withIndent('  ').convert(jsonList);
        jpSentence = prettyJsonString
            .replaceAll('  ', '')
            .replaceAll('[\n', '')
            .replaceAll(']\n', '')
            .replaceAll(']', '');
      }
      if (i == 5) break;
      sentence.add(CommonAnimatedListItem(
        key: ValueKey('example_jp_$i'),
        animationDuration: Duration(milliseconds: 300 * (i + 1)),
        child: Padding(
          padding: EdgeInsets.only(right: 10, top: 9),
          child: Text(
            jpSentence,
            style: TextStyle(
                fontSize: Constants.definitionTextSize,
                fontWeight: FontWeight.bold),
          ),
        ),
      ));
      if (exampleSentence[i].targetSentence != null) {
        sentence.add(CommonAnimatedListItem(
          key: ValueKey('example_target_$i'),
          animationDuration: Duration(milliseconds: 300 * (i + 1)),
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 2),
            child: Text(
              exampleSentence[i].targetSentence ?? '',
              style: TextStyle(fontSize: Constants.definitionTextSize),
            ),
          ),
        ));
      }
    }
    return sentence;
  }
}
