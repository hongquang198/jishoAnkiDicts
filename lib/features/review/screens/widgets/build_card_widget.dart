// import 'dart:convert';
//
// import 'package:JapaneseOCR/models/dictionary.dart';
// import 'package:JapaneseOCR/services/dbHelper.dart';
// import 'package:JapaneseOCR/services/kanjiHelper.dart';
// import 'package:JapaneseOCR/utils/offlineListType.dart';
// import 'package:JapaneseOCR/widgets/definition_screen/component_widget.dart';
// import 'package:JapaneseOCR/widgets/definition_screen/definition_tags.dart';
// import 'package:JapaneseOCR/widgets/definition_screen/definition_widget.dart';
// import 'package:JapaneseOCR/widgets/definition_screen/example_sentence_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'answerButton.dart';
//
// class CardWidget extends StatefulWidget {
//   final Dictionary dictionary;
//   final BuildContext context;
//   final int currentCard;
//   final List<int> step;
//   CardWidget(
//       {Key? key, this.currentCard, this.dictionary, this.context, this.step})
//       : super(key: key);
//
//   @override
//   _CardWidgetState createState() => _CardWidgetState();
// }
//
// class _CardWidgetState extends State<CardWidget> {
//   bool showAll = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Expanded(
//         child: ListView(children: <Widget>[
//           SizedBox(
//             height: 10,
//           ),
//           showAll == true &&
//                   KanjiHelper.getPitchAccent(
//                           word: widget
//                                   .dictionary.review[widget.currentCard].word ??
//                               '',
//                           slug: widget
//                                   .dictionary.review[widget.currentCard].slug ??
//                               '',
//                           reading: widget.dictionary.review[widget.currentCard]
//                                   .reading ??
//                               '',
//                           pitchAccentDict: widget.dictionary.pitchAccentDict) !=
//                       null
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: KanjiHelper.getPitchAccent(
//                       word: widget.dictionary.review[widget.currentCard].word ??
//                           '',
//                       slug: widget.dictionary.review[widget.currentCard].slug ??
//                           '',
//                       reading: widget
//                               .dictionary.review[widget.currentCard].reading ??
//                           '',
//                       pitchAccentDict: widget.dictionary.pitchAccentDict),
//                 )
//               : SizedBox(),
//           Center(
//             child: Text(
//               widget.dictionary.review[widget.currentCard].word ??
//                   widget.dictionary.review[widget.currentCard].slug ??
//                   widget.dictionary.review[widget.currentCard].reading ??
//                   '',
//               style: TextStyle(
//                 fontSize: 45.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           showAll == true
//               ? Center(
//                   child: Text(
//                     KanjiHelper.getHanvietReading(
//                             word: widget
//                                 .dictionary.review[widget.currentCard].word,
//                             kanjiDict: widget.dictionary.kanjiDictionary)
//                         .toString()
//                         .toUpperCase(),
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                   ),
//                 )
//               : SizedBox(),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               widget.dictionary.review[widget.currentCard].is_common == 1
//                   ? Card(
//                       color: Color(0xFF8ABC82),
//                       child: Text(
//                         'common word',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     )
//                   : SizedBox(),
//               DefinitionTags(
//                   tags: jsonDecode(
//                       widget.dictionary.review[widget.currentCard].tags),
//                   color: Color(0xFF909DC0)),
//               DefinitionTags(
//                   tags: jsonDecode(
//                       widget.dictionary.review[widget.currentCard].jlpt),
//                   color: Color(0xFF909DC0)),
//             ],
//           ),
//           SizedBox(height: 8),
//           showAll == true
//               ? Center(
//                   child: DefinitionWidget(
//                     senses: jsonDecode(
//                         widget.dictionary.review[widget.currentCard].senses),
//                     vietnameseDefinition: widget.dictionary
//                         .review[widget.currentCard].vietnamese_definition,
//                   ),
//                 )
//               : SizedBox(),
//           Divider(),
//           showAll == true
//               ? Center(
//                   child: Text(
//                     'Examples',
//                     style: TextStyle(
//                       color: Color(0xffDB8C8A),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 25,
//                     ),
//                   ),
//                 )
//               : SizedBox(),
//           showAll == true
//               ? Padding(
//                   padding: EdgeInsets.only(left: 12, right: 12),
//                   child: ExampleSentenceWidget(
//                       word: widget.dictionary.review[widget.currentCard].slug ??
//                           widget.dictionary.review[widget.currentCard].word),
//                 )
//               : SizedBox(),
//           Divider(),
//           showAll == true
//               ? Center(
//                   child: Text(
//                     'Components',
//                     style: TextStyle(
//                       color: Color(0xffDB8C8A),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 25,
//                     ),
//                   ),
//                 )
//               : SizedBox(),
//           showAll == true
//               ? Padding(
//                   padding: EdgeInsets.only(left: 12, right: 12),
//                   child: ComponentWidget(
//                     kanjiList: KanjiHelper.extractKanji(
//                         word: widget.dictionary.review[widget.currentCard].word,
//                         kanjiDict: widget.dictionary.kanjiDictionary),
//                   ),
//                 )
//               : SizedBox(),
//         ]),
//       ),
//       TextField(
//         decoration: InputDecoration(hintText: 'Enter your answer'),
//       ),
//       SizedBox(height: 5),
//       if (showAll == false)
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               showAll = true;
//             });
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: 50,
//             color: Color(0xFF385499),
//             child: Center(
//               child: Text(
//                 'Show answer',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         )
//       else
//         Container(
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     widget.dictionary.review[widget.currentCard].ease = 2.5;
//                     showAll = false;
//                     if (widget.dictionary.review[widget.currentCard].reviews ==
//                         0) {
//                       widget.dictionary.review[widget.currentCard].firstReview =
//                           DateTime.now().millisecondsSinceEpoch;
//                     } else {
//                       // If card is mature
//                       if (widget
//                               .dictionary.review[widget.currentCard].interval >
//                           21 * 24 * 60 * 60 * 1000) {
//                         widget.dictionary.review[widget.currentCard].lapses++;
//                       }
//                     }
//                     widget.dictionary.review[widget.currentCard].lastReview =
//                         DateTime.now().millisecondsSinceEpoch;
//                     widget.dictionary.review[widget.currentCard].due =
//                         DateTime.now().millisecondsSinceEpoch + 1 * 60 * 1000;
//                     widget.dictionary.review[widget.currentCard].interval =
//                         widget.dictionary.review[widget.currentCard].due -
//                             widget.dictionary.review[widget.currentCard]
//                                 .lastReview;
//                     widget.dictionary.review[widget.currentCard].reviews++;
//                     DbHelper.updateWordInfo(
//                         offlineListType: OfflineListType.review,
//                         context: context,
//                         senses: jsonDecode(widget
//                             .dictionary.review[widget.currentCard].senses),
//                         offlineWordRecord:
//                             widget.dictionary.review[widget.currentCard]);
//                     widget.currentCard++;
//                   });
//                 },
//                 child: AnswerButton(
//                     currentCard: widget.currentCard,
//                     step: widget.step,
//                     buttonText: 'Again',
//                     color: Colors.red),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showAll = false;
//                     widget.dictionary.review[widget.currentCard].lastReview =
//                         DateTime.now().millisecondsSinceEpoch;
//                     if (widget.dictionary.review[widget.currentCard].reviews ==
//                         0)
//                       widget.dictionary.review[widget.currentCard].firstReview =
//                           DateTime.now().millisecondsSinceEpoch;
//                     if (widget.dictionary.review[widget.currentCard].interval <
//                         10 * 60 * 1000) {
//                       widget.dictionary.review[widget.currentCard].due =
//                           DateTime.now().millisecondsSinceEpoch +
//                               10 * 60 * 1000;
//                     }
//                     if (widget.dictionary.review[widget.currentCard].interval >=
//                             10 * 60 * 1000 &&
//                         widget.dictionary.review[widget.currentCard].interval <
//                             1 * 24 * 60 * 60 * 999) {
//                       widget.dictionary.review[widget.currentCard].due =
//                           DateTime.now().millisecondsSinceEpoch +
//                               1 * 24 * 60 * 60 * 1000;
//                     }
//                     if (widget.dictionary.review[widget.currentCard].interval >=
//                         1 * 24 * 60 * 60 * 1000) {
//                       widget.dictionary.review[widget.currentCard].due =
//                           DateTime.now().millisecondsSinceEpoch +
//                               (widget.dictionary.review[widget.currentCard]
//                                           .interval *
//                                       widget.dictionary
//                                           .review[widget.currentCard].ease)
//                                   .round();
//                     }
//                     widget.dictionary.review[widget.currentCard].interval =
//                         widget.dictionary.review[widget.currentCard].due -
//                             widget.dictionary.review[widget.currentCard]
//                                 .lastReview;
//
//                     widget.dictionary.review[widget.currentCard].reviews++;
//                     DbHelper.updateWordInfo(
//                         offlineListType: OfflineListType.review,
//                         context: context,
//                         senses: jsonDecode(widget
//                             .dictionary.review[widget.currentCard].senses),
//                         offlineWordRecord:
//                             widget.dictionary.review[widget.currentCard]);
//                     widget.currentCard++;
//                   });
//                 },
//                 child: AnswerButton(
//                     currentCard: widget.currentCard,
//                     step: widget.step,
//                     buttonText: 'Good',
//                     color: Colors.green),
//               )
//             ],
//           ),
//         ),
//     ]);
//   }
// }
