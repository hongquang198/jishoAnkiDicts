class JishoDefinition {
  String slug;
  bool isCommon;
  List<dynamic> tags;
  List<dynamic> jlpt;
  String word;
  String reading;
  List<dynamic> senses;
  // List<dynamic> english_definitions;
  // List<dynamic> parts_of_speech;
  // List<dynamic> links;
  // List<dynamic> see_also;
  // List<dynamic> antonyms;
  // List<dynamic> source;
  // List<dynamic> info;

  dynamic isJmdict;
  dynamic isJmnedict;
  dynamic isDbpedia;

  JishoDefinition({
    this.slug,
    this.isCommon,
    this.tags,
    this.jlpt,
    this.word,
    this.reading,
    this.senses,
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
}
