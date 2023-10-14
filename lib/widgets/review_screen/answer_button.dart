import '../../injection.dart';
import '../../models/offline_word_record.dart';
import '../../core/data/datasources/shared_pref.dart';
import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    Key? key,
    required this.steps,
    required this.color,
    required this.buttonText,
    required this.offlineWordRecord,
  }) : super(key: key);
  final OfflineWordRecord offlineWordRecord;
  final List<int> steps;
  final Color color;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: TextStyle(color: Colors.white),
            ),
            if (buttonText == 'Again') Text('1m') else getInterval()
          ],
        ),
      ),
    );
  }

  Widget getInterval() {
    if (offlineWordRecord.interval < steps[steps.length - 1] * 60 * 1000)
      for (int i = 0; i < steps.length; i++) {
        if (offlineWordRecord.interval < steps[i] * 60 * 1000) {
          return Text('${steps[i]}min');
        }
      }
    else if (offlineWordRecord.interval ==
        steps[steps.length - 1] * 60 * 1000) {
      return Text('${getIt<SharedPref>().prefs.getInt('graduatingInterval')}day');
    } else if (offlineWordRecord.interval >=
        getIt<SharedPref>().prefs.getInt('graduatingInterval')! * 24 * 60 * 60 * 1000) {
      if (offlineWordRecord.interval * offlineWordRecord.ease <=
          31 * 24 * 60 * 60 * 1000) {
        return Text(
            '${Duration(milliseconds: (offlineWordRecord.interval * offlineWordRecord.ease).round()).inDays}day');
      } else if (offlineWordRecord.interval * offlineWordRecord.ease <=
          365 * 24 * 60 * 60 * 1000) {
        return Text(
            '${(Duration(milliseconds: (offlineWordRecord.interval * offlineWordRecord.ease).round()).inDays / 31).toStringAsFixed(1)}month');
      }
      return Text(
          '${(Duration(milliseconds: (offlineWordRecord.interval * offlineWordRecord.ease).round()).inDays / 365).toStringAsFixed(1)}year');
    }
    return Text('');
  }
}

// if (dictionary.review[currentCard].reviews > 0 == true)
// dictionary.review[currentCard].interval / 1000 / 60 < 60
// ? Text(
// '${(dictionary.review[currentCard].interval / 1000 / 60).round()}m',
// style: TextStyle(color: Colors.white),
// )
// : Text(
// '${(dictionary.review[currentCard].interval / 1000 / 60 / 60 / 24).round()}d',
// style: TextStyle(color: Colors.white),
// )
// else
// buttonText == 'Good'
// ? Text(
// '${step[1].round().toString()}m',
// style: TextStyle(color: Colors.white),
// )
// : Text(
// '${step[0].round().toString()}m',
// style: TextStyle(color: Colors.white),
// ),
