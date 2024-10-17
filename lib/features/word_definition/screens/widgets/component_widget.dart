import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../injection.dart';
import '../../mixins/kanji_detail_mixin.dart';
import '/models/kanji.dart';
import '/utils/constants.dart';

class ComponentWidget extends StatelessWidget {
  final Future<List<Kanji>> kanjiComponent;
  ComponentWidget({required this.kanjiComponent});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Kanji>>(
        future: kanjiComponent,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Column();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < (snapshot.data!.length); i++)
                SingleKanjiComponentWidget(
                  kanji: snapshot.data![i],
                  animationDuration: Duration(
                    milliseconds: (i + 1) * 500,
                  ),
                ),
            ],
          );
        });
  }
}

class SingleKanjiComponentWidget extends StatefulWidget {
  final Kanji kanji;
  final Duration animationDuration;
  const SingleKanjiComponentWidget({
    super.key,
    required this.kanji,
    required this.animationDuration,
  });

  @override
  State<SingleKanjiComponentWidget> createState() => _SingleKanjiComponentWidgetState();
}

class _SingleKanjiComponentWidgetState extends State<SingleKanjiComponentWidget>
    with KanjiDetailMixin {
  bool postFrame = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          postFrame = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: postFrame ? 80 : 0,
      duration: widget.animationDuration,
      curve: Curves.elasticOut,
      child: GestureDetector(
        onTap: () {
          showKanjiDetails(context, kanji: widget.kanji);
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
            getIt<SharedPref>().isAppInVietnamese
                ? (widget.kanji.kanji ?? '') + ' ' + (widget.kanji.hanViet ?? '')
                : (widget.kanji.kanji ?? ''),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Constants.definitionTextSize,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'On: ${widget.kanji.onYomi} Kun: ${widget.kanji.kunYomi}',
                style: TextStyle(color: Colors.grey),
                softWrap: false,
              ),
              Text(
                widget.kanji.keyword ?? '',
                style: TextStyle(
                  fontSize: Constants.definitionTextSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}