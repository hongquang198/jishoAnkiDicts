import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:unofficial_jisho_api/api.dart';

import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../injection.dart';
import '/utils/constants.dart';

class DefinitionWidget extends StatelessWidget {
  final String? vietnameseDefinition;
  final List<JishoWordSense>? senses;
  DefinitionWidget({this.vietnameseDefinition, this.senses});

  getVnDefinitionWidget() {
    List<String> example = [];
    if (vietnameseDefinition == null) return SizedBox();

    var document = parse(vietnameseDefinition);

    var fontList = document.querySelectorAll("font");

    var imgList = document.querySelectorAll("img");

    var pList = document.querySelectorAll("p");

    var brList = document.querySelectorAll("br");

    for (dom.Element br in brList) {
      br.remove();
    }

    for (dom.Element img in imgList) {
      img.remove();
    }

    for (dom.Element p in pList) {
      if (p.attributes["class"] == "nv_a") p.remove();
    }
    for (dom.Element font in fontList) {
      // word type
      if (font.attributes["color"] == '#0066ff') {
      }

      //Example
      if (font.attributes["color"] == '#144A14') {
        example.add(font.text);
      }
      if (getIt<SharedPref>().prefs.getString('theme') == 'dark')
        font.attributes["color"] = '0xffffff';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, right: 15),
      child: HtmlWidget(
        document.outerHtml,
        textStyle: TextStyle(
          fontSize: Constants.definitionTextSize,
          color: getIt<SharedPref>().prefs.getString('theme') == 'dark'
              ? Colors.white
              : null,
        ),
        customStylesBuilder: (element) {
          if (element.className.contains('nv_b'))
            return {
              "list-style-type": "upper-roman",
              "align": "left",
              "margin-left": "0px",
              "padding-left": "0px"
            };
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String definition = '';
    for (int i = 0; i < (senses?.length ?? 0); i++) {
      String definitionAtIndex = senses?[i].toString() ?? '';
      if (definitionAtIndex.length > 0) {
        definitionAtIndex =
            definitionAtIndex.substring(1, definitionAtIndex.length - 1);
        definition = definition + definitionAtIndex;
      }
      if (i != (senses?.length ?? 0) - 1) {
        definition = definition + '\n\n';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getIt<SharedPref>().isAppInVietnamese
            ? getVnDefinitionWidget()
            : SizedBox(),
        if ((getIt<SharedPref>().isAppInEnglish) ||
            vietnameseDefinition?.isEmpty == true)
          for (int i = 0; i < (senses?.length ?? 0); i++) getDefinitions(i),
      ],
    );
  }

  Widget getDefinitions(int index) {
    if (senses == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          senses![index].partsOfSpeech
              .toString()
              .substring(
                  1, senses![index].partsOfSpeech.toString().length - 1)
              .toUpperCase(),
          style: TextStyle(fontSize: 12),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, bottom: 10, top: 5),
          child: Text(
            senses![index].englishDefinitions.toString().substring(
                1, senses![index].englishDefinitions.toString().length - 1),
            style: TextStyle(
                fontSize: Constants.definitionTextSize,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
