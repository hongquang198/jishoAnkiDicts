import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:typed_data';
import 'dart:ui';

import '../injection.dart';
import '../utils/constants.dart';
import 'media_query_size.dart';

final _canvasCullRect = Rect.fromPoints(
  Offset(0, 0),
  Offset(Constants.imageSize, Constants.imageSize),
);

final _whitePaint = Paint()
  ..strokeCap = StrokeCap.round
  ..color = Colors.white
  ..strokeWidth = Constants.strokeWidth;

final _bgPaint = Paint()..color = Colors.black;

class Recognizer {
  Future loadModel({required String modelPath, required String labelPath}) {
    Tflite.close();
    return Tflite.loadModel(
      model: modelPath,
      labels: labelPath,
    );
  }

  dispose() {
    Tflite.close();
  }

  Future<Uint8List> previewImage(List<Offset> points) async {
    final picture = _pointsToPicture(points);
    final image = await picture.toImage(
        Constants.writingImageSize, Constants.writingImageSize);
    var pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes?.buffer.asUint8List() ?? Uint8List(0);
  }

  Future recognize(List<Offset?> points) async {
    final picture = _pointsToPicture(points);
    Uint8List bytes =
        await _imageToByteListUint8(picture, Constants.writingImageSize);
    return _predict(bytes);
  }

  Future _predict(Uint8List bytes) {
    return Tflite.runModelOnBinary(binary: bytes);
  }

  Future<Uint8List> _imageToByteListUint8(Picture pic, int size) async {
    final img = await pic.toImage(size, size);
    final imgBytes = await img.toByteData();
    final resultBytes = Float32List(size * size);
    final buffer = Float32List.view(resultBytes.buffer);

    int index = 0;

    for (int i = 0; i < (imgBytes?.lengthInBytes ?? 0); i += 4) {
      final r = imgBytes?.getUint8(i) ?? 0;
      final g = imgBytes?.getUint8(i + 1) ?? 0;
      final b = imgBytes?.getUint8(i + 2) ?? 0;
      buffer[index++] = (r + g + b) / 3.0 / 255.0;
    }

    return resultBytes.buffer.asUint8List();
  }

  Picture _pointsToPicture(List<Offset?> points) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _canvasCullRect)
      ..scale(Constants.writingImageSize / getIt<MediaQuerySize>().canvasSize);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, Constants.imageSize, Constants.imageSize),
        _bgPaint);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, _whitePaint);
      }
    }
    return recorder.endRecording();
  }
}
