import '/utils/barTitleType.dart';
import 'package:flutter/material.dart';

class BarLine extends StatelessWidget {
  /// This numner determines the height of the bar line
  /// depending on the maximum height. Actual height will be number/maxNumber*const predetermined height.
  final double number;

  /// This number determine the maximum height of all the bar lines.
  final double maxNumber;

  /// Determine the color of the bar line.
  final Color color;

  /// Determine the title of the bar line.
  final String? barTitle;

  /// Determine the width of the bar line.
  final double barWidth;

  /// Determine the base height of the bar line.
  final double baseHeight;

  /// Determine where the title of the bar line is shown
  final BarTitleType barTitleType;

  /// Determine should the number be shown on top of the bar line
  final bool showNumber;

  /// 0 if not specified
  final double? borderRadius;

  /// Determine the maximun height a bar line can have. Default = 100
  final double maxHeightPixel;

  final EdgeInsetsGeometry padding;
  const BarLine(
      {Key? key,
      this.maxHeightPixel = 100,
      this.showNumber = false,
      this.borderRadius,
      required this.barWidth,
      required this.number,
      required this.maxNumber,
      required this.color,
      this.barTitle,
      required this.baseHeight,
      this.barTitleType = BarTitleType.hidden,
      this.padding = const EdgeInsets.only(left: 15.0, right: 15.0)})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              showNumber == true
                  ? Text(
                      number.toInt().toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : SizedBox(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      width: barWidth,
                      // 130 is the total height of the container
                      height: number != 0
                          ? (baseHeight + (number / maxNumber) * maxHeightPixel)
                          : baseHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: borderRadius == null
                            ? BorderRadius.all(
                                Radius.circular(4),
                              )
                            : BorderRadius.all(
                                Radius.circular(borderRadius!),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              barTitleType == BarTitleType.under && barTitle != null
                  ? SizedBox(
                      height: 20,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          barTitle!,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SizedBox()
            ],
          ),
          barTitleType == BarTitleType.rightSideBar && barTitle != null
              ? Text(
                  barTitle!,
                  style: TextStyle(color: Colors.grey),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
