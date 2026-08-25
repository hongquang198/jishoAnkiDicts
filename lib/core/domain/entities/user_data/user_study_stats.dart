import 'package:equatable/equatable.dart';

/// Forecast data for a single day.
class DayForecast extends Equatable {
  final DateTime date;
  final String dayLabel;
  final int newCards;
  final int youngCards;
  final int matureCards;
  final int difficultCards;

  const DayForecast({
    required this.date,
    required this.dayLabel,
    this.newCards = 0,
    this.youngCards = 0,
    this.matureCards = 0,
    this.difficultCards = 0,
  });

  int get totalDue => newCards + youngCards + matureCards + difficultCards;

  @override
  List<Object?> get props => [date, dayLabel, newCards, youngCards, matureCards, difficultCards];
}

/// Aggregated user learning metrics.
class UserStudyStats extends Equatable {
  final int dueToday;
  final int newCount;
  final int youngCount;
  final int matureCount;
  final int difficultCount;
  final double retentionRate; // 0.0 to 1.0
  final List<DayForecast> sevenDaysForecast;
  final Map<String, int> activityHeatmap; // ISO date string 'YYYY-MM-DD' -> review count

  const UserStudyStats({
    this.dueToday = 0,
    this.newCount = 0,
    this.youngCount = 0,
    this.matureCount = 0,
    this.difficultCount = 0,
    this.retentionRate = 0.0,
    this.sevenDaysForecast = const [],
    this.activityHeatmap = const {},
  });

  @override
  List<Object?> get props => [
        dueToday,
        newCount,
        youngCount,
        matureCount,
        difficultCount,
        retentionRate,
        sevenDaysForecast,
        activityHeatmap,
      ];
}
