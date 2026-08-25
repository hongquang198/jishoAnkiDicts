import 'package:flutter/material.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';

class WordViewCountWidget extends StatelessWidget {
  final int? viewCounts;
  final String? word;
  final bool onlyShowNumber;
  final EdgeInsets margin;

  const WordViewCountWidget({
    this.viewCounts,
    this.word,
    this.onlyShowNumber = false,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (viewCounts != null) {
      return _buildContainer(context, viewCounts!);
    }

    if (word != null && word!.isNotEmpty) {
      return StreamBuilder<Map<String, WordViewRecord>>(
        stream: getIt<UserDataRepository>().watchWordViews(),
        builder: (context, snapshot) {
          final count = snapshot.data?[word]?.viewCount ?? 0;
          return _buildContainer(context, count);
        },
      );
    }

    return _buildContainer(context, 0);
  }

  Widget _buildContainer(BuildContext context, int count) {
    return Container(
      margin: margin,
      width: onlyShowNumber ? 22 : 60,
      height: onlyShowNumber ? 18 : 40,
      decoration: const BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Center(
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: onlyShowNumber ? 10 : 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!onlyShowNumber)
                Text(
                  AppLocalizations.of(context)!.views,
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
