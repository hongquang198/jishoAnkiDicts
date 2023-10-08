import '../../../core/domain/entities/dictionary.dart';
import '../../../utils/constants.dart';
import '../../../widgets/statistics_screen/predictionChart.dart';
import '../../../widgets/statistics_screen/todayDueChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
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
                newCardNumber: dictionary.getNewCardNumber.toDouble(),
                youngCardNumber: dictionary.getYoungCardNumber.toDouble(),
                matureCardNumber: dictionary.getMatureCardNumber.toDouble(),
                difficultCardNumber:
                    dictionary.getDifficultCardNumber.toDouble(),
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
    });
  }
}

class HeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
