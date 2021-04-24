class ExampleSentence {
  String jpSentenceId;
  String vnSentenceId;
  String jpSentence;
  String vnSentence;
  ExampleSentence(
      {this.jpSentence, this.vnSentence, this.jpSentenceId, this.vnSentenceId});

  Map<String, dynamic> toMap() {
    return {
      'jpSentenceId': jpSentenceId,
      'vnSentenceId': vnSentenceId,
      'jpSentence': jpSentence,
      'vnSentence': vnSentence,
    };
  }
}
