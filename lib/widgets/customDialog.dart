import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
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
                  'Card has reached lapses threshold (${SharedPref.prefs.getInt('leechThreshold')} times wrong) and has been moved to your favorite list since you probably need to revisit it.',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Got It!',
                  style: TextStyle(fontSize: 18.0),
                ))
          ],
        ),
      ),
    );
  }
}
