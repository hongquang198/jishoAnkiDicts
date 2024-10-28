// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../common/widgets/common_animated_list_item.dart';
import '../../../../models/example_sentence.dart';
import '/utils/constants.dart';

class ExampleSentenceWidget extends StatelessWidget {
  final Future<List<ExampleSentence>> exampleSentence;
  const ExampleSentenceWidget({
    Key? key,
    required this.exampleSentence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExampleSentence>>(
        future: exampleSentence,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.connectionState != ConnectionState.done) {
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

class __ExampleSentenceWidgetState extends State<_ExampleSentenceWidget> {
  OverlayEntry? sticky;
  GlobalKey stickyKey = GlobalKey();
  final controller = ScrollController();

  @override
  void initState() {
    sticky?.remove();

    sticky = OverlayEntry(
      builder: (context) => stickyBuilder(context),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (sticky != null) {
        // Overlay.of(context).insert(sticky!);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    sticky?.remove();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      key: stickyKey,
      controller: controller,
      children: generateSentence(widget.exampleSentences),
    );
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
      sentence.add(CommonAnimatedListItem(
        animationDuration: Duration(milliseconds: 300 * (i+1)),
        child: Padding(
          padding: EdgeInsets.only(right: 10, top: 9),
          child: Text(
            exampleSentence[i].jpSentence ?? '',
            style: TextStyle(
                fontSize: Constants.definitionTextSize,
                fontWeight: FontWeight.bold),
          ),
        ),
      ));
      if (exampleSentence[i].targetSentence != null)
        sentence.add(CommonAnimatedListItem(
        animationDuration: Duration(milliseconds: 300 * (i+1)),
        child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 2),
            child: Text(
              exampleSentence[i].targetSentence ?? '',
              style: TextStyle(fontSize: Constants.definitionTextSize),
            ),
          ),
        ));
    }
    return sentence;
  }

  Widget stickyBuilder(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final keyContext = stickyKey.currentContext;
        if (keyContext != null) {
          // widget is visible
          final box = keyContext.findRenderObject() as RenderBox;
          final pos = box.localToGlobal(Offset.zero);
          return Positioned(
            top: pos.dy,
            right: pos.dx,
            height: box.size.height,
            width: box.size.width,
            child: Material(
              child: Container(
                alignment: Alignment.center,
                color: Colors.purple,
                child: const Text("^ Nah I think you're okay"),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}