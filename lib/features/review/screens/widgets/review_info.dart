import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../core/domain/entities/dictionary.dart';
import '../../../../injection.dart';
import '../../../../models/offline_word_record.dart';
import '../../../../utils/card_status.dart';

class ReviewInfo extends StatefulWidget {
  final OfflineWordRecord offlineWordRecord;
  ReviewInfo({required this.offlineWordRecord});

  @override
  _ReviewInfoState createState() => _ReviewInfoState();
}

class _ReviewInfoState extends State<ReviewInfo> {
  late List<OfflineWordRecord> review;
  late List<int> steps;

  @override
  void initState() {
    steps = getIt<SharedPref>().prefs
        .getStringList('newCardsSteps')
        ?.map((e) => int.parse(e))
        .toList() ?? [];
    super.initState();
  }

  CardStatus getCardStatus() {
    if (widget.offlineWordRecord.reviews == 0)
      return CardStatus.isNew;
    else if (widget.offlineWordRecord.interval <=
        steps[steps.length - 1] * 60 * 1000)
      return CardStatus.isLearned;
    else if (widget.offlineWordRecord.due <
        DateTime.now().millisecondsSinceEpoch) return CardStatus.isDue;
    return CardStatus.isNew;
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
