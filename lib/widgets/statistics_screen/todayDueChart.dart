import '/utils/barTitleType.dart';
import '/utils/constants.dart';
import '/utils/sharedPref.dart';
import 'package:flutter/material.dart';

import 'barLine.dart';

class TodayDueChart extends StatefulWidget {
  final double newCardNumber;
  final double youngCardNumber;
  final double matureCardNumber;
  final double difficultCardNumber;

  const TodayDueChart(
      {Key key,
      this.newCardNumber = 0,
      this.youngCardNumber = 0,
      this.difficultCardNumber = 0,
      this.matureCardNumber = 0})
      : super(key: key);

  @override
  _TodayDueChartState createState() => _TodayDueChartState();
}

class _TodayDueChartState extends State<TodayDueChart> {
  double maxCardNumber() {
    double max = widget.newCardNumber;
    if (widget.youngCardNumber > max) max = widget.youngCardNumber;
    if (widget.matureCardNumber > max) max = widget.matureCardNumber;
    if (widget.difficultCardNumber > max) max = widget.difficultCardNumber;
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: BarLine(
                showNumber: true,
                number: widget.newCardNumber,
                maxNumber: maxCardNumber(),
                color: Color(0xFFF4DDDC),
                barTitle: 'New',
                baseHeight: 20,
                barWidth: 20,
                barTitleType: BarTitleType.rightSideBar,
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
              ),
            ),
            Expanded(
              child: BarLine(
                showNumber: true,
                number: widget.youngCardNumber,
                maxNumber: maxCardNumber(),
                color: Color(0xFFDB8C8A),
                barTitle: 'Young',
                baseHeight: 20,
                barWidth: 20,
                barTitleType: BarTitleType.rightSideBar,
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
              ),
            ),
            Expanded(
              child: BarLine(
                showNumber: true,
                number: widget.matureCardNumber,
                maxNumber: maxCardNumber(),
                color: Colors.black,
                barTitle: 'Mature',
                baseHeight: 20,
                barWidth: 20,
                barTitleType: BarTitleType.rightSideBar,
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
              ),
            ),
            Expanded(
              child: BarLine(
                showNumber: true,
                number: widget.difficultCardNumber,
                maxNumber: maxCardNumber(),
                color: Colors.grey,
                barTitle: 'Difficult',
                baseHeight: 20,
                barWidth: 20,
                barTitleType: BarTitleType.rightSideBar,
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        SharedPref.prefs.getString('language') == 'English'
            ? Text(
                'There are ${(widget.newCardNumber + widget.youngCardNumber + widget.matureCardNumber + widget.difficultCardNumber).toInt()} cards due today.',
                style: TextStyle(fontSize: Constants.definitionTextSize))
            : Text(
                'Hôm nay có ${(widget.newCardNumber + widget.youngCardNumber + widget.matureCardNumber + widget.difficultCardNumber).toInt()} thẻ đến hạn.',
                style: TextStyle(fontSize: Constants.definitionTextSize),
              ),
      ],
    );
  }
}
