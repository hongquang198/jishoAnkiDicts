import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class YAxisNumberLine extends StatefulWidget {
  /// Determines the height of the Y axis
  final double maximumHeightPixel;

  /// Determines the maximum height of bar line
  /// The value of each horizontal line is calculated as: its height (pixel, relative to 0)/barLineMaximumHeightPixel*maxNumber
  final double barLineMaximumHeightPixel;

  /// This property will be used to show scale of the vertical bar
  final double totalNumberOfCards;

  /// Determines the maximum number of card types. For example, if mature cards: 148 cards, young: 20 cards, new: 120 cards
  /// => Maximum number is 148. This number is used to calculate the ratio of rod bar to get its value
  /// The value of each horizontal line is calculated as: its height (pixel, relative to 0)/barLineMaximumHeightPixel*maxNumber
  final double highestCardNumber;
  const YAxisNumberLine(
      {Key key,
      this.totalNumberOfCards = 0,
      this.maximumHeightPixel,
      this.highestCardNumber = 100,
      this.barLineMaximumHeightPixel})
      : super(key: key);

  @override
  _YAxisNumberLineState createState() => _YAxisNumberLineState();
}

class _YAxisNumberLineState extends State<YAxisNumberLine> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            widget.totalNumberOfCards > 280
                ? getHorizontalLine(value: 300)
                : SizedBox(),
            widget.totalNumberOfCards > 260
                ? getHorizontalLine(value: 280)
                : SizedBox(),
            widget.totalNumberOfCards > 240
                ? getHorizontalLine(value: 260)
                : SizedBox(),
            widget.totalNumberOfCards > 220
                ? getHorizontalLine(value: 240)
                : SizedBox(),
            widget.totalNumberOfCards > 200
                ? getHorizontalLine(value: 220)
                : SizedBox(),
            widget.totalNumberOfCards > 180
                ? getHorizontalLine(value: 200)
                : SizedBox(),
            widget.totalNumberOfCards > 160
                ? getHorizontalLine(value: 180)
                : SizedBox(),
            widget.totalNumberOfCards > 140
                ? getHorizontalLine(value: 160)
                : SizedBox(),
            widget.totalNumberOfCards > 120
                ? getHorizontalLine(value: 140)
                : SizedBox(),
            widget.totalNumberOfCards > 100
                ? getHorizontalLine(value: 120)
                : SizedBox(),
            widget.totalNumberOfCards > 80
                ? getHorizontalLine(value: 100)
                : SizedBox(),
            widget.totalNumberOfCards > 60
                ? getHorizontalLine(value: 80)
                : SizedBox(),
            widget.totalNumberOfCards > 40
                ? getHorizontalLine(value: 60)
                : SizedBox(),
            widget.totalNumberOfCards > 20
                ? getHorizontalLine(value: 40)
                : SizedBox(),
            widget.totalNumberOfCards > 10
                ? getHorizontalLine(value: 20)
                : SizedBox(),
            widget.totalNumberOfCards > 8 && widget.totalNumberOfCards < 20
                ? getHorizontalLine(value: 10)
                : SizedBox(),
            widget.totalNumberOfCards > 6 && widget.totalNumberOfCards < 10
                ? getHorizontalLine(value: 8)
                : SizedBox(),
            widget.totalNumberOfCards > 4 && widget.totalNumberOfCards < 10
                ? getHorizontalLine(value: 6)
                : SizedBox(),
            widget.totalNumberOfCards > 2 && widget.totalNumberOfCards < 10
                ? getHorizontalLine(value: 4.0)
                : SizedBox(),
            widget.totalNumberOfCards > 1 && widget.totalNumberOfCards < 10
                ? getHorizontalLine(value: 2)
                : SizedBox(),
            widget.totalNumberOfCards > 0 && widget.totalNumberOfCards < 10
                ? getHorizontalLine(value: 1)
                : SizedBox(),
            getHorizontalLine(value: 0),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Padding getHorizontalLine({double value}) {
    return Padding(
      padding: EdgeInsets.only(bottom: getHorizontalLineHeight(value: value)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value.toInt().toString(),
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Divider(
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate the height of the horizontal bar (pixel) with respect to its value
  double getHorizontalLineHeight({double value}) {
    if (widget.highestCardNumber != 0)
      return (value / widget.highestCardNumber) *
          widget.barLineMaximumHeightPixel;
    return 0;
  }
}
