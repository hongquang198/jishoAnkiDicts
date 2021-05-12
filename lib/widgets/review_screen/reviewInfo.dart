import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/utils/cardStatus.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewInfo extends StatefulWidget {
  final OfflineWordRecord offlineWordRecord;
  ReviewInfo({this.offlineWordRecord});

  @override
  _ReviewInfoState createState() => _ReviewInfoState();
}

class _ReviewInfoState extends State<ReviewInfo> {
  List<OfflineWordRecord> review;
  List<int> steps;

  @override
  void initState() {
    steps = SharedPref.prefs
        .getStringList('newCardsSteps')
        .map((e) => int.parse(e))
        .toList();
    super.initState();
  }

  // ignore: missing_return
  CardStatus getCardStatus() {
    if (widget.offlineWordRecord.reviews == 0)
      return CardStatus.isNew;
    else if (widget.offlineWordRecord.interval <=
        steps[steps.length - 1] * 60 * 1000)
      return CardStatus.isLearned;
    else if (widget.offlineWordRecord.due <
        DateTime.now().millisecondsSinceEpoch) return CardStatus.isDue;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
      return Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
              bottom: getCardStatus() == CardStatus.isNew
                  ? BorderSide(
                      color: Colors.blue,
                    )
                  : BorderSide(color: Colors.white),
            )),
            child: Text(
              '${dictionary.getNewCardNumber}',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
                border: Border(
              bottom: getCardStatus() == CardStatus.isLearned
                  ? BorderSide(
                      color: Colors.red,
                    )
                  : BorderSide(color: Colors.white),
            )),
            child: Text(
              '${dictionary.getLearnedCardNumber}',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
                border: Border(
              bottom: getCardStatus() == CardStatus.isDue
                  ? BorderSide(
                      color: Colors.green,
                    )
                  : BorderSide(color: Colors.white),
            )),
            child: Text(
              '${dictionary.getDueCardNumber}',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    });
  }
}
