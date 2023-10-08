import 'package:equatable/equatable.dart';
import 'package:unofficial_jisho_api/api.dart';

class JishoDefinition extends Equatable {
  final String slug;
  final bool isCommon;
  final List<String> tags;
  final List<String> jlpt;
  final String? word;
  final String? reading;
  final List<JishoWordSense> senses;
  // List<dynamic> english_definitions;
  // List<dynamic> parts_of_speech;
  // List<dynamic> links;
  // List<dynamic> see_also;
  // List<dynamic> antonyms;
  // List<dynamic> source;
  // List<dynamic> info;

  final dynamic isJmdict;
  final dynamic isJmnedict;
  final dynamic isDbpedia;

  String get japaneseWord {
    if (word?.isNotEmpty == true) {
      return word!;
    } else if (slug.isNotEmpty == true) {
      return slug;
    }
    return reading ?? '';
  }

  const JishoDefinition({
    required this.slug,
    this.isCommon = false,
    this.tags = const [],
    this.jlpt = const [],
    this.word,
    this.reading,
    this.senses = const [],
    // this.english_definitions,
    // this.parts_of_speech,
    // this.links,
    // this.see_also,
    // this.antonyms,
    // this.source,
    // this.info,
    this.isJmdict,
    this.isJmnedict,
    this.isDbpedia,
  });
  
  @override
  List<Object?> get props => [
    slug,
        isCommon,
        tags,
        jlpt,
        word,
        reading,
        senses,
        isJmdict,
        isJmnedict,
        isDbpedia,
  ];
}
