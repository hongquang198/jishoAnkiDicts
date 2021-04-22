import 'dart:typed_data';

import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/services/load_dictionary.dart';
import 'package:JapaneseOCR/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:JapaneseOCR/models/prediction.dart';
import 'file:///C:/Users/ADMIN/AndroidStudioProjects/JapaneseOCR/lib/widgets/drawing_painter.dart';
import 'package:JapaneseOCR/services/recognizer.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:provider/provider.dart';

import 'kanji_screen.dart';

class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final _points = List<Offset>();
  final _recognizer = Recognizer();
  List<Prediction> _prediction;
  List<Prediction> _prediction2;
  bool initialize = false;
  bool firstModelPredictionHasFinished = true;
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";

  @override
  void initState() {
    super.initState();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _prediction?.isNotEmpty ?? false
                  ? PredictionWidget(
                      predictions: _prediction,
                      kanjiAll:
                          Provider.of<Dictionary>(context).kanjiDictionary,
                    )
                  : Container(height: 36, width: 36, color: Colors.black),
              _prediction2?.isNotEmpty ?? false
                  ? PredictionWidget(
                      predictions: _prediction2,
                      kanjiAll:
                          Provider.of<Dictionary>(context).kanjiDictionary,
                    )
                  : Container(height: 36, width: 36, color: Colors.black),
            ],
          ),
          _drawCanvasWidget(),
        ],
      ),
    );
  }

  Widget _drawCanvasWidget() {
    return Container(
      width: Constants.canvasSize + Constants.borderSize * 2,
      height: Constants.canvasSize + Constants.borderSize * 2,
      decoration: BoxDecoration(
        color: Color(0xFFF7E7E6),
        border: Border.all(
          color: Color(0xFFF7E7E6),
          width: Constants.borderSize,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          Offset _localPosition = details.localPosition;
          if (_localPosition.dx >= 0 &&
              _localPosition.dx <= Constants.canvasSize &&
              _localPosition.dy >= 0 &&
              _localPosition.dy <= Constants.canvasSize) {
            setState(() {
              _points.add(_localPosition);
            });
          }
        },
        onPanEnd: (DragEndDetails details) async {
          _points.add(null);
          await _recognize();
          await _initModel(
              modelFilePath: modelFilePath2, labelFilePath: labelFilePath2);

          await _recognize(isForSecondModel: true);
          await _initModel(
              modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
        },
        child: CustomPaint(
          painter: DrawingPainter(_points),
        ),
      ),
    );
  }

  Future _initModel({String modelFilePath, String labelFilePath}) async {
    var res = await _recognizer.loadModel(
        modelPath: modelFilePath, labelPath: labelFilePath);
  }

  Future<Uint8List> _previewImage() async {
    return await _recognizer.previewImage(_points);
  }

  Future _recognize({bool isForSecondModel = false}) async {
    List<dynamic> pred = await _recognizer.recognize(_points);
    setState(() {
      if (!isForSecondModel)
        _prediction = pred.map((json) => Prediction.fromJson(json)).toList();
      else {
        _prediction2 = pred.map((json) => Prediction.fromJson(json)).toList();
      }
    });
  }
}

// floatingActionButton: FloatingActionButton(
// child: Icon(Icons.clear),
// onPressed: () {
// setState(() {
// _points.clear();
// _prediction.clear();
// _prediction2.clear();
// });
// },
// ),
