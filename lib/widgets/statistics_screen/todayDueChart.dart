import 'package:JapaneseOCR/utils/barTitleType.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:flutter/cupertino.dart';
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BarLine(
              showNumber: true,
              number: widget.newCardNumber,
              maxNumber: maxCardNumber(),
              color: Color(0xFFF4DDDC),
              barTitle: 'New',
              baseHeight: 20,
              barWidth: 20,
              barTitleType: BarTitleType.rightSideBar,
            ),
            BarLine(
              showNumber: true,
              number: widget.youngCardNumber,
              maxNumber: maxCardNumber(),
              color: Color(0xFFDB8C8A),
              barTitle: 'Young',
              baseHeight: 20,
              barWidth: 20,
              barTitleType: BarTitleType.rightSideBar,
            ),
            BarLine(
              showNumber: true,
              number: widget.matureCardNumber,
              maxNumber: maxCardNumber(),
              color: Colors.black,
              barTitle: 'Mature',
              baseHeight: 20,
              barWidth: 20,
              barTitleType: BarTitleType.rightSideBar,
            ),
            BarLine(
              showNumber: true,
              number: widget.difficultCardNumber,
              maxNumber: maxCardNumber(),
              color: Colors.grey,
              barTitle: 'Difficult',
              baseHeight: 20,
              barWidth: 20,
              barTitleType: BarTitleType.rightSideBar,
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Text(
          'There are 160 cards due today.',
          style: TextStyle(fontSize: Constants.definitionTextSize),
        )
      ],
    );
  }
}
