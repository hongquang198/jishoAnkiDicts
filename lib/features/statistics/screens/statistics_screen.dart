import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/features/statistics/bloc/statistics_bloc.dart';
import 'package:jisho_anki/features/statistics/screens/widgets/activity_heatmap_widget.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/utils/constants.dart';

import 'widgets/prediction_chart.dart';
import 'widgets/today_due_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StatisticsBloc>()..add(const LoadStudyStats()),
      child: const _StatisticsScreenView(),
    );
  }
}

class _StatisticsScreenView extends StatelessWidget {
  const _StatisticsScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.statistics,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatisticsLoaded) {
            final stats = state.stats;
            final retentionPct = (stats.retentionRate * 100).toStringAsFixed(1);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Statistics today',
                  style: TextStyle(
                    color: Color(0xffDB8C8A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                TodayDueChart(
                  newCardNumber: stats.newCount.toDouble(),
                  youngCardNumber: stats.youngCount.toDouble(),
                  matureCardNumber: stats.matureCount.toDouble(),
                  difficultCardNumber: stats.difficultCount.toDouble(),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricTile('Total Due', '${stats.dueToday}'),
                        _buildMetricTile('Retention', '$retentionPct%'),
                        _buildMetricTile('Leech/Difficult', '${stats.difficultCount}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    color: Color(0xffDB8C8A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                PredictionChart(forecast: stats.sevenDaysForecast),
                const SizedBox(height: 24),
                ActivityHeatmapWidget(activityData: stats.activityHeatmap),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMetricTile(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
