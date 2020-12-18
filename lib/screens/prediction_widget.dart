import 'package:flutter/material.dart';
import 'package:mnistdigitrecognizer/models/prediction.dart';

class PredictionWidget extends StatelessWidget {
  final List<Prediction> predictions;
  const PredictionWidget({Key key, this.predictions}) : super(key: key);

  Widget getPrediction(Prediction prediction) {
    predictions?.forEach((prediction) {
      int index = prediction.index;
      String label = prediction.label;
      double confidence = prediction.confidence;
      print('index $index label $label confidence $confidence');
    });
    return Text(prediction.label + prediction.confidence.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ));
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
