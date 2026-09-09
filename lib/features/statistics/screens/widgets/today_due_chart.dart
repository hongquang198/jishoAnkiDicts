import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/bar_title_type.dart';
import '/utils/constants.dart';

import 'package:jisho_anki/features/statistics/screens/widgets/bar_line.dart';

class TodayDueChart extends StatefulWidget {
  final double newCardNumber;
  final double youngCardNumber;
  final double matureCardNumber;
  final double difficultCardNumber;

  const TodayDueChart(
      {super.key,
      this.newCardNumber = 0,
      this.youngCardNumber = 0,
      this.difficultCardNumber = 0,
      this.matureCardNumber = 0});

  @override
  State<TodayDueChart> createState() => _TodayDueChartState();
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
    final l = AppLocalizations.of(context)!;
    final dueTotal = (widget.newCardNumber +
            widget.youngCardNumber +
            widget.matureCardNumber +
            widget.difficultCardNumber)
        .toInt();
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
                barTitle: l.dueNew,
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
                barTitle: l.dueYoung,
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
                barTitle: l.dueMature,
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
                barTitle: l.dueDifficult,
                baseHeight: 20,
                barWidth: 20,
                barTitleType: BarTitleType.rightSideBar,
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Text(l.cardsDueToday(dueTotal),
            style: TextStyle(fontSize: Constants.definitionTextSize)),
      ],
    );
  }
}
