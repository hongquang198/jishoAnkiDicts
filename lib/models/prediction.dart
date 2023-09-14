class Prediction {
  final double confidence;
  final int index;
  final String label;

  Prediction({this.confidence = 0, this.index = -1, this.label = ''});

  factory Prediction.fromJson(Map<dynamic, dynamic> json) {
    return Prediction(
      confidence: json['confidence'],
      index: json['index'],
      label: json['label'],
    );
  }
}
