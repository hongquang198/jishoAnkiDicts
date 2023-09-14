class GrammarPoint {
  String enSentence;
  String jpSentence;
  String jlptLevel;
  String grammarMeaning;
  String romanSentence;
  String grammarPoint;
  GrammarPoint(
      {required this.enSentence,
      required this.jpSentence,
      required this.jlptLevel,
      required this.grammarMeaning,
      required this.romanSentence,
      required this.grammarPoint});

  Map<String, dynamic> toMap() {
    return {
      'enSentence': enSentence,
      'jpSentence': jpSentence,
      'jlptLevel': jlptLevel,
      'grammarMeaning': grammarMeaning,
      'romanSentence': romanSentence,
      'grammarPoint': grammarPoint,
    };
  }
}
