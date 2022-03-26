import '/models/dictionary.dart';
import '/models/offlineWordRecord.dart';
import '/utils/barTitleType.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'YAxisNumberLine.dart';
import 'barLine.dart';

class PredictionChart extends StatefulWidget {
  @override
  _PredictionChartState createState() => _PredictionChartState();
}

class _PredictionChartState extends State<PredictionChart> {
  /// List of card number.
  /// For example matureCardNumber[0] = Today's mature card number, matureCardNumber[1] = Tomorrow's new card number
  /// youngCardNumber[6] = Young card number 8 days from now
  /// 6 is max (weekly interval)
  double newCardNumber;
  List<double> youngCardNumber = [0, 0, 0, 0, 0, 0, 0];
  List<double> matureCardNumber = [0, 0, 0, 0, 0, 0, 0];
  double difficultCardNumber;
  List<OfflineWordRecord> review;

  double highestCardTypeNumber() {
    double maxYoung = youngCardNumber.reduce(max);
    double maxMature = matureCardNumber.reduce(max);
    return max(
        max(newCardNumber, difficultCardNumber), max(maxYoung, maxMature));
  }

  double maxReviewNumberPerDay() {
    List<double> sum = [0, 0, 0, 0, 0, 0, 0];
    for (int i = 0; i < 7; i++) {
      sum[0] = newCardNumber +
          youngCardNumber[i] +
          matureCardNumber[i] +
          difficultCardNumber;
    }
    return sum.reduce(max);
  }

  void getCardNumber() {
    newCardNumber = 0;
    difficultCardNumber = 0;

    review.forEach((element) {
      // Find number of new cards
      if (element.reviews == 0) newCardNumber++;
      // Find number of young cards
      if (element.reviews != 0) {
        if (element.interval <= 21 * 24 * 60 * 60 * 1000)
          for (int i = 0; i < 7; i++) {
            if (element.due <
                DateTime.now().millisecondsSinceEpoch + i * 24 * 60 * 60 * 1000)
              youngCardNumber[i]++;
          }
      }

      if (element.interval > 21 * 24 * 60 * 60 * 1000)
        for (int i = 0; i < 7; i++) {
          if (element.due <
              i * 24 * 60 * 60 * 1000 + DateTime.now().millisecondsSinceEpoch)
            matureCardNumber[i]++;
        }
      if (element.lapses > 5) difficultCardNumber++;
    });
  }

  @override
  void initState() {
    review = Provider.of<Dictionary>(context, listen: false).review;
    getCardNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PredictionLineBar(
                  barTitle: '月',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[0],
                  matureCardNumber: matureCardNumber[0],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
                PredictionLineBar(
                  barTitle: '火',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[1],
                  matureCardNumber: matureCardNumber[1],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
                PredictionLineBar(
                  barTitle: '水',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[2],
                  matureCardNumber: matureCardNumber[2],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
                PredictionLineBar(
                  barTitle: '木',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[3],
                  matureCardNumber: matureCardNumber[3],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
                PredictionLineBar(
                  barTitle: '金',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[4],
                  matureCardNumber: matureCardNumber[4],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
                PredictionLineBar(
                  barTitle: '土',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[5],
                  matureCardNumber: matureCardNumber[5],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
                PredictionLineBar(
                  barTitle: '日',
                  newCardNumber: newCardNumber,
                  youngCardNumber: youngCardNumber[6],
                  matureCardNumber: matureCardNumber[6],
                  difficultCardNumber: difficultCardNumber,
                  maxNumber: highestCardTypeNumber(),
                ),
              ],
            ),
            SizedBox(height: 10.0),
          ],
        ),
        YAxisNumberLine(
          totalNumberOfCards: maxReviewNumberPerDay(),
          maximumHeightPixel: 200,
          barLineMaximumHeightPixel: 100,
          highestCardNumber: highestCardTypeNumber(),
        ),
      ],
    );
  }
}

class PredictionLineBar extends StatelessWidget {
  final double newCardNumber;
  final double youngCardNumber;
  final double matureCardNumber;
  final double difficultCardNumber;

  /// Max number of all card types in 7 days
  final double maxNumber;
  final String barTitle;

  const PredictionLineBar({
    @required this.barTitle,
    this.difficultCardNumber = 0,
    this.matureCardNumber = 0,
    this.newCardNumber = 0,
    this.youngCardNumber = 0,
    this.maxNumber = 0,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BarLine(
          number: newCardNumber,
          maxNumber: maxNumber,
          color: Color(0xFFF4DDDC),
          baseHeight: 0,
          barWidth: 7,
          borderRadius: 0,
        ),
        BarLine(
          number: youngCardNumber,
          maxNumber: maxNumber,
          color: Color(0xFFDB8C8A),
          baseHeight: 0,
          barWidth: 7,
          borderRadius: 0,
        ),
        BarLine(
          number: difficultCardNumber,
          maxNumber: maxNumber,
          color: Colors.grey,
          barTitle: barTitle,
          baseHeight: 0,
          barWidth: 7,
          borderRadius: 0,
        ),
        BarLine(
          number: matureCardNumber,
          maxNumber: maxNumber,
          color: Colors.black,
          baseHeight: 0,
          barWidth: 7,
          barTitle: barTitle,
          barTitleType: BarTitleType.under,
          borderRadius: 0,
        ),
      ],
    );
  }
}
