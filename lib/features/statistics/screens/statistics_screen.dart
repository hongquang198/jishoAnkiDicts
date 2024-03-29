import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/domain/entities/dictionary.dart';
import '../../../injection.dart';
import '../../../utils/constants.dart';

import 'widgets/prediction_chart.dart';
import 'widgets/today_due_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.statistics,
            style: TextStyle(color: Constants.appBarTextColor),
          ),
        ),
        body: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics today',
                style: TextStyle(
                  color: Color(0xffDB8C8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TodayDueChart(
                newCardNumber: getIt<Dictionary>().getNewCardNumber.toDouble(),
                youngCardNumber: getIt<Dictionary>().getYoungCardNumber.toDouble(),
                matureCardNumber: getIt<Dictionary>().getMatureCardNumber.toDouble(),
                difficultCardNumber:
                    getIt<Dictionary>().getDifficultCardNumber.toDouble(),
              ),
              SizedBox(height: 10.0),
              Text(
                'This week',
                style: TextStyle(
                  color: Color(0xffDB8C8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10.0),
              PredictionChart(),
              HeatMap(),
            ],
          ),
        ]),
      );
  }
}

class HeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
