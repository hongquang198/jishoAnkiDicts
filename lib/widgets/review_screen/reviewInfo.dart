import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewInfo extends StatefulWidget {
  @override
  _ReviewInfoState createState() => _ReviewInfoState();
}

class _ReviewInfoState extends State<ReviewInfo> {
  List<OfflineWordRecord> review;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dictionary>(builder: (context, dictionary, child) {
      return Row(
        children: [
          Text(
            '${dictionary.getNewCardNumber}',
            style: TextStyle(color: Colors.blue),
          ),
          SizedBox(width: 5),
          Text(
            '${dictionary.getLearnedCardNumber}',
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(width: 5),
          Text(
            '${dictionary.getDueCardNumber}',
            style: TextStyle(color: Colors.green),
          ),
        ],
      );
    });
  }
}
