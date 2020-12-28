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
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 30.0,
                            horizontal: 5.0,
                          ),
                          child: Text(
                            "${kanji?.kanji ?? ''}",
                            style: TextStyle(
                              fontSize: 120.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Card(
                                  margin: EdgeInsets.only(
                                    top: 15.0,
                                    bottom: 5.0,
                                  ),
                                  child: Text(
                                    "N${kanji?.jlpt ?? '0'}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.only(
                                    top: 15.0,
                                    bottom: 5.0,
                                    left: 3.0,
                                  ),
                                  child: Text(
                                    "Cấp độ ${kanji?.jouYou ?? '0'}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Card(
                              color: Colors.white,
                              child: Text(
                                "${kanji?.strokeCount ?? '0'} nét",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Hán việt: ",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          child: Text(
                            "${kanji?.hanViet ?? ''}",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Row(
                      children: [
                        Text(
                          "Keyword: ",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          child: Text(
                            "${kanji?.keyword ?? ''}",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text(
                      "Âm Onyomi: ${kanji?.onYomi ?? ''}",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text(
                      "Âm Kunyomi: ${kanji?.kunYomi ?? ''}",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text(
                      "Ví dụ: ${kanji?.readingExamples ?? ''}",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text(
                      "Mẹo nhớ : ${kanji?.koohiiStory1 ?? 'Chưa có'}",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
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
