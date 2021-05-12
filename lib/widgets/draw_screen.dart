import 'dart:typed_data';
import 'dart:ui';
import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/services/load_dictionary.dart';
import 'package:JapaneseOCR/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:JapaneseOCR/models/prediction.dart';
import 'package:JapaneseOCR/widgets/drawing_painter.dart';
import 'package:JapaneseOCR/services/recognizer.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:provider/provider.dart';
import 'kanji_screen.dart';

class DrawScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  DrawScreen({this.textEditingController});
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  var _points = List<Offset>();
  final _recognizer = Recognizer();
  List<Prediction> _prediction;
  List<Prediction> _prediction2;
  bool initialize = false;
  bool firstModelPredictionHasFinished = true;
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";
  var lastStrokes = List<Offset>();

  List<Kanji> kanjiDict = [];

  @override
  void initState() {
    kanjiDict = Provider.of<Dictionary>(context, listen: false).kanjiDictionary;
    super.initState();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  List<Prediction> allPredictions() {
    List<Prediction> all = [];
    if (_prediction != null && _prediction2 != null) {
      all.addAll(_prediction);
      all.addAll(_prediction2);
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        InputSelectionBar(),
        allPredictions()?.isNotEmpty ?? false
            ? PredictionWidget(
                clearStrokes: () {
                  setState(() {
                    _points.clear();
                  });
                },
                textEditingController: widget.textEditingController,
                predictions: allPredictions(),
                kanjiAll: kanjiDict,
              )
            : SizedBox(),
        Expanded(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _drawCanvasWidget(),
              ),
              canvasOptions(context),
            ],
          ),
        ),
      ],
    );
  }

  Expanded canvasOptions(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                // Goal is to remove all points between last 2 null values in _points array
                if (_points.length > 0) {
                  _points.removeAt(_points.length - 1);
                  for (int i = _points.length - 1; i > 0; i--) {
                    if (_points[i] != null)
                      _points.removeAt(i);
                    else {
                      recognizePoints();
                      return;
                    }
                  }
                }
              });
            },
            child: Icon(
              Icons.undo,
              size: 30,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _points.clear();
                _prediction.clear();
                _prediction2.clear();
              });
            },
            child: Icon(
              Icons.cancel,
              size: 33,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.textEditingController.text.length != 0)
                widget.textEditingController.text = widget
                    .textEditingController.text
                    .substring(0, widget.textEditingController.text.length - 1);
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Color(0xFFDB8C8A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.keyboard_backspace,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 33,
            ),
          ),
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
              lastStrokes.add(_localPosition);
              _points.add(_localPosition);
            });
          }
        },
        onPanEnd: (DragEndDetails details) async {
          _points.add(null);
          recognizePoints();
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

  void recognizePoints() async {
    await _recognize();
    await _initModel(
        modelFilePath: modelFilePath2, labelFilePath: labelFilePath2);

    await _recognize(isForSecondModel: true);
    await _initModel(
        modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }
}

class InputSelectionBar extends StatelessWidget {
  const InputSelectionBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 40,
            color: Color(0xFFDB8C8A),
            child: Center(
              child: Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFDB8C8A),
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 4.5),
            ),
          ),
          width: MediaQuery.of(context).size.width / 2,
          height: 40,
          child: Center(
            child: Icon(
              Icons.brush_sharp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
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
