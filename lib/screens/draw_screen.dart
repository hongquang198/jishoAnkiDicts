import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mnistdigitrecognizer/models/prediction.dart';
import 'package:mnistdigitrecognizer/screens/drawing_painter.dart';
import 'package:mnistdigitrecognizer/screens/prediction_widget.dart';
import 'package:mnistdigitrecognizer/services/recognizer.dart';
import 'package:mnistdigitrecognizer/utils/constants.dart';

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
  final modelFilePath1 = "assets/mnist.tflite";
  final labelFilePath1 = "assets/mnist.txt";
  final modelFilePath2 = "assets/mnist2.tflite";
  final labelFilePath2 = "assets/label3036.txt";

  @override
  void initState() {
    super.initState();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Japanese Recognizer'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'ETL database of handwritten Japanese',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'The digits have been size-normalized and centered in a fixed-size images (28 x 28)',
                        )
                      ],
                    ),
                  ),
                ),
                _mnistPreviewImage(),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            _drawCanvasWidget(),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ignore: null_aware_in_condition
                _prediction?.isNotEmpty ?? false
                    ? Column(
                        children: [
                          Text(
                            "Dataset 879",
                            style: TextStyle(color: Colors.blue),
                          ),
                          PredictionWidget(
                            predictions: _prediction,
                          ),
                        ],
                      )
                    : Container(),
                // ignore: null_aware_in_condition
                _prediction2?.isNotEmpty ?? false
                    ? Column(
                        children: [
                          Text("Dataset 3036",
                              style: TextStyle(color: Colors.blue)),
                          PredictionWidget(
                            predictions: _prediction2,
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        child: Icon(Icons.clear),
        onPressed: () {
          setState(() {
            _points.clear();
            _prediction.clear();
            _prediction2.clear();
          });
        },
      ),
    );
  }

  Widget _drawCanvasWidget() {
    return Container(
      width: Constants.canvasSize + Constants.borderSize * 2,
      height: Constants.canvasSize + Constants.borderSize * 2,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: Constants.borderSize,
        ),
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

  Widget _mnistPreviewImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.black,
      child: FutureBuilder(
        future: _previewImage(),
        builder: (BuildContext _, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data,
              fit: BoxFit.fill,
            );
          } else {
            return Center(
              child: Text('Error'),
            );
          }
        },
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
      else
        _prediction2 = pred.map((json) => Prediction.fromJson(json)).toList();
    });
  }
}
