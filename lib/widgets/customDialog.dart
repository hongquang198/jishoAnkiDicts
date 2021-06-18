import 'package:JapaneseOCR/services/dbHelper.dart';
import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String word;
  final String message;
  CustomDialog({this.word, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 220.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'NOTICE',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      DbHelper.removeFromOfflineList(
                        offlineListType: OfflineListType.history,
                        word: word,
                        context: context,
                      );

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Understood',
                      style: TextStyle(fontSize: 18.0),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 18.0),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
