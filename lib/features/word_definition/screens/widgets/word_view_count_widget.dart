import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class WordViewCountWidget extends StatelessWidget {
  final int viewCounts;
  final bool onlyShowNumber;
  final EdgeInsets margin;

  const WordViewCountWidget({
    required this.viewCounts,
    this.onlyShowNumber = false,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        width: onlyShowNumber ? 22 : 60,
        height: onlyShowNumber ? 18 : 40,
        decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.all(Radius.circular(6))),
        child: Center(
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(viewCounts.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: onlyShowNumber ? 10 : 17,
                        fontWeight: FontWeight.bold)),
                if (!onlyShowNumber)
                  Text(
                    AppLocalizations.of(context)!.views,
                    style: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        ));
  }
}
