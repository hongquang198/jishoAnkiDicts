import 'package:JapaneseOCR/models/kanji.dart';
import 'package:flutter/material.dart';
import 'package:JapaneseOCR/models/prediction.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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

  Widget getPrediction(BuildContext context, Prediction prediction) {
    predictions?.forEach((prediction) {
      int index = prediction.index;
      String label = prediction.label;
      double confidence = prediction.confidence;
      print('index $index label $label confidence $confidence');
    });
    return GestureDetector(
      onTap: () {
        var kanji = getKanji(prediction.label);
        return showCupertinoModalBottomSheet(
            expand: true,
            context: context,
            builder: (context) => Material(
                    child: Container(
                        child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("HanViet: ${kanji?.hanViet ?? ''}")],
                  ),
                ))));
      },
      child: Text(prediction.label + prediction.confidence.toStringAsFixed(4),
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
          for (var prediction in predictions) getPrediction(context, prediction)
        ]);
  }
}
