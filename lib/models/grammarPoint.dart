class GrammarPoint {
  String enSentence;
  String jpSentence;
  String jlptLevel;
  String grammarMeaning;
  String romanSentence;
  String grammarPoint;
  GrammarPoint(
      {this.enSentence,
      this.jpSentence,
      this.jlptLevel,
      this.grammarMeaning,
      this.romanSentence,
      this.grammarPoint});

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
