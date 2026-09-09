import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/db_helper.dart';
import '../../utils/offline_list_type.dart';

class CustomDialog extends StatelessWidget {
  final String word;
  final String message;
  const CustomDialog({super.key, required this.word, required this.message});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: SizedBox(
        height: 220.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                l.notice,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                      l.understood,
                      style: const TextStyle(fontSize: 18.0),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l.cancel,
                      style: const TextStyle(fontSize: 18.0),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
