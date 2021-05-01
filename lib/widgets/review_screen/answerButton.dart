import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    Key key,
    @required this.currentCard,
    @required this.steps,
    @required this.color,
    @required this.buttonText,
  }) : super(key: key);

  final int currentCard;
  final List<int> steps;
  final Color color;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
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
              if (buttonText == 'Again') Text('1m') else getInterval(dictionary)
            ],
          ),
        ),
      );
    });
  }

  Text getInterval(Dictionary dictionary) {
    if (dictionary.review[currentCard].interval <
        steps[steps.length - 1] * 60 * 1000)
      for (int i = 0; i < steps.length; i++) {
        if (dictionary.review[currentCard].interval < steps[i] * 60 * 1000) {
          return Text('${steps[i]}min');
        }
      }
    else if (dictionary.review[currentCard].interval ==
        steps[steps.length - 1] * 60 * 1000) {
      return Text('${SharedPref.prefs.getInt('graduatingInterval')}day');
    } else if (dictionary.review[currentCard].interval >=
        SharedPref.prefs.getInt('graduatingInterval') * 24 * 60 * 60 * 1000) {
      if (dictionary.review[currentCard].interval *
              dictionary.review[currentCard].ease <=
          31 * 24 * 60 * 60 * 1000) {
        return Text(
            '${Duration(milliseconds: (dictionary.review[currentCard].interval * dictionary.review[currentCard].ease).round()).inDays}day');
      } else if (dictionary.review[currentCard].interval *
              dictionary.review[currentCard].ease <=
          365 * 24 * 60 * 60 * 1000) {
        return Text(
            '${(Duration(milliseconds: (dictionary.review[currentCard].interval * dictionary.review[currentCard].ease).round()).inDays / 31).toStringAsFixed(1)}month');
      }
      return Text(
          '${(Duration(milliseconds: (dictionary.review[currentCard].interval * dictionary.review[currentCard].ease).round()).inDays / 365).toStringAsFixed(1)}year');
    }
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
