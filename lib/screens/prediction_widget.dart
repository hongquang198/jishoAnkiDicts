import 'package:JapaneseOCR/models/kanji.dart';
import 'package:flutter/material.dart';
import 'package:JapaneseOCR/models/prediction.dart';

class PredictionWidget extends StatelessWidget {
  final List<Prediction> predictions;
  final List<Kanji> kanjiAll;
  const PredictionWidget({Key key, this.predictions, this.kanjiAll})
      : super(key: key);

  Kanji getKanji(String label) {
    Kanji kanji = kanjiAll.firstWhere((element) => element.kanji == label,
        orElse: () => null);
    return kanji;
  }

  Widget getPrediction(Prediction prediction) {
    predictions?.forEach((prediction) {
      int index = prediction.index;
      String label = prediction.label;
      double confidence = prediction.confidence;
      print('index $index label $label confidence $confidence');
    });
    return Tooltip(
      message: getKanji(prediction.label).hanViet,
      child: Text(prediction.label + prediction.confidence.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (var prediction in predictions) getPrediction(prediction)
        ]);
  }
}
