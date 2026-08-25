import 'package:flutter/material.dart';
import 'dart:math';

import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import '../../../../utils/bar_title_type.dart';
import 'y_axis_number_line.dart';
import 'bar_line.dart';

class PredictionChart extends StatelessWidget {
  final List<DayForecast> forecast;

  const PredictionChart({
    super.key,
    this.forecast = const [],
  });

  double highestCardTypeNumber() {
    if (forecast.isEmpty) return 1;
    double maxVal = 0;
    for (final day in forecast) {
      maxVal = max(maxVal, day.newCards.toDouble());
      maxVal = max(maxVal, day.youngCards.toDouble());
      maxVal = max(maxVal, day.matureCards.toDouble());
      maxVal = max(maxVal, day.difficultCards.toDouble());
    }
    return max(1.0, maxVal);
  }

  double maxReviewNumberPerDay() {
    if (forecast.isEmpty) return 1;
    double maxVal = 0;
    for (final day in forecast) {
      maxVal = max(maxVal, day.totalDue.toDouble());
    }
    return max(1.0, maxVal);
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No forecast data available.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final maxNumber = highestCardTypeNumber();

    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: forecast.map((day) {
                return PredictionLineBar(
                  barTitle: day.dayLabel,
                  newCardNumber: day.newCards.toDouble(),
                  youngCardNumber: day.youngCards.toDouble(),
                  matureCardNumber: day.matureCards.toDouble(),
                  difficultCardNumber: day.difficultCards.toDouble(),
                  maxNumber: maxNumber,
                );
              }).toList(),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
        YAxisNumberLine(
          totalNumberOfCards: maxReviewNumberPerDay(),
          maximumHeightPixel: 200,
          barLineMaximumHeightPixel: 100,
          highestCardNumber: maxNumber,
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
  final double maxNumber;
  final String barTitle;

  const PredictionLineBar({
    required this.barTitle,
    this.difficultCardNumber = 0,
    this.matureCardNumber = 0,
    this.newCardNumber = 0,
    this.youngCardNumber = 0,
    this.maxNumber = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BarLine(
          number: newCardNumber,
          maxNumber: maxNumber,
          color: const Color(0xFFF4DDDC),
          baseHeight: 0,
          barWidth: 7,
          borderRadius: 0,
        ),
        BarLine(
          number: youngCardNumber,
          maxNumber: maxNumber,
          color: const Color(0xFFDB8C8A),
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
