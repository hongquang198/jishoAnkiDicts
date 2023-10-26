import 'package:flutter/material.dart';
import 'package:jisho_anki/features/main_search/presentation/screens/widgets/draw_screen.dart';

import '/models/kanji.dart';
import '/models/prediction.dart';

class PredictionWidget extends StatefulWidget {
  final List<Prediction> predictions;
  final List<Kanji> kanjiAll;
  final TextEditingController textEditingController;
  final Function clearStrokes;
  const PredictionWidget(
      {Key? key,
      required this.predictions,
      required this.kanjiAll,
      required this.textEditingController,
      required this.clearStrokes})
      : super(key: key);

  @override
  _PredictionWidgetState createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  Widget getPrediction(BuildContext context, Prediction prediction) {
    return GestureDetector(
      onTap: () {
        widget.textEditingController.text =
            widget.textEditingController.text + prediction.label;
        widget.clearStrokes();
      },
      child: Container(
        width: DrawScreenConst.canvasOptionMaxSize,
        height: DrawScreenConst.canvasOptionMaxSize,
        decoration: BoxDecoration(
          color: widget.predictions[0] == prediction
              ? Color(0xFFDB8C8A)
              : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(prediction.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var prediction in widget.predictions)
          getPrediction(context, prediction),
      ],
    );
  }
}
