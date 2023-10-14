class GrammarPoint {
  final String? enSentence;
  final String? jpSentence;
  final String? jlptLevel;
  final String? grammarMeaning;
  final String? romanSentence;
  final String? grammarPoint;
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
