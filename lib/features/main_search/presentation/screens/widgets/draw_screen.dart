import 'package:flutter/material.dart';
import 'package:jisho_anki/services/media_query_size.dart';

import '../../../../../injection.dart';
import '../../../../word_definition/screens/widgets/kanji_drawboard.dart';
import '/models/kanji.dart';
import '/models/prediction.dart';
import '/services/recognizer.dart';
import '/utils/constants.dart';
import 'drawing_painter.dart';

class DrawScreenConst {
  static const double canvasOptionMaxSize = 35;
  static const EdgeInsets canvasPadding = EdgeInsets.only(left: 10.0);
}

class DrawScreen extends StatefulWidget {
  final TextEditingController textEditingController;
  const DrawScreen({
    required this.textEditingController,
    super.key,
  });
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Offset?> _points = [];
  final _recognizer = Recognizer();
  late List<Prediction> _prediction;
  late List<Prediction> _prediction2;
  bool initialize = false;
  bool firstModelPredictionHasFinished = true;
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";
  List<Offset> lastStrokes = [];
  List<Kanji> kanjiDict = [];

  @override
  void initState() {
    _prediction = [];
    _prediction2 = [];
    super.initState();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  List<Prediction> allPredictions() {
    List<Prediction> all = [];
    if (_prediction.isNotEmpty && _prediction2.isNotEmpty) {
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
        allPredictions().isNotEmpty
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
            : SizedBox(height: DrawScreenConst.canvasOptionMaxSize),
        Expanded(
          child: Row(
            children: <Widget>[
              Padding(
                padding: DrawScreenConst.canvasPadding,
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
              width: DrawScreenConst.canvasOptionMaxSize,
              height: DrawScreenConst.canvasOptionMaxSize,
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
      width: getIt<MediaQuerySize>().canvasSize +
          Constants.borderSize * 2,
      height: getIt<MediaQuerySize>().canvasSize +
          Constants.borderSize * 2,
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
              _localPosition.dx <= getIt<MediaQuerySize>().canvasSize &&
              _localPosition.dy >= 0 &&
              _localPosition.dy <= getIt<MediaQuerySize>().canvasSize) {
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

  Future _initModel({required String modelFilePath, required String labelFilePath}) async {
    await _recognizer.loadModel(
        modelPath: modelFilePath, labelPath: labelFilePath);
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
    Key? key,
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
