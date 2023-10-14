import '../../injection.dart';
import '/models/kanji.dart';
import '../../core/data/datasources/shared_pref.dart';
import 'package:flutter/material.dart';
import '/utils/constants.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComponentWidget extends StatefulWidget {
  final Future<List<Kanji>> kanjiComponent;
  ComponentWidget({required this.kanjiComponent});

  @override
  _ComponentWidgetState createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  Widget getKanjiComponents(Kanji kanji) {
    return GestureDetector(
      onTap: () {
        showKanjiDetails(kanji);
      },
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 0),
        trailing: Padding(
          padding: EdgeInsets.only(right: 18),
          child: Container(
              width: 40,
              height: 25,
              decoration: BoxDecoration(
                  color: Color(0xffDB8C8A),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.view,
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ),
        title: Text(
          getIt<SharedPref>().prefs.getString('language') == ('Tiếng Việt')
              ? (kanji.kanji ?? '') + ' ' + (kanji.hanViet ?? '')
              : (kanji.kanji ?? ''),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Constants.definitionTextSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'On: ${kanji.onYomi} Kun: ${kanji.kunYomi}',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              kanji.keyword ?? '',
              style: TextStyle(
                fontSize: Constants.definitionTextSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showKanjiDetails(Kanji kanji) {
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
                        "${kanji.kanji ?? ''}",
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
                                "N${kanji.jlpt ?? '0'}",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.only(
                                top: 15.0,
                                bottom: 5.0,
                                left: 3.0,
                              ),
                              child: Text(
                                "Cấp độ ${kanji.jouYou ?? '0'}",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Card(
                          child: Text(
                            "${kanji.strokeCount ?? '0'} nét",
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
                      child: Text(
                        "${kanji.hanViet ?? ''}",
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
                      child: Text(
                        "${kanji.keyword ?? ''}",
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
                  "Âm Onyomi: ${kanji.onYomi ?? ''}",
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
                  "Âm Kunyomi: ${kanji.kunYomi ?? ''}",
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
                  "Ví dụ: ${kanji.readingExamples ?? ''}",
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
                  "Mẹo nhớ : ${kanji.koohiiStory1 ?? 'Chưa có'}",
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
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Kanji>>(
        future: widget.kanjiComponent,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Column();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < (snapshot.data!.length); i++)
                getKanjiComponents(snapshot.data![i]),
            ],
          );
        });
  }
}
