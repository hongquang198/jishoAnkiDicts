class JishoDefinition {
  String slug;
  bool is_common;
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

  dynamic is_jmdict;
  dynamic is_jmnedict;
  dynamic is_dbpedia;

  JishoDefinition({
    this.slug,
    this.is_common,
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
    this.is_jmdict,
    this.is_jmnedict,
    this.is_dbpedia,
  });
}
