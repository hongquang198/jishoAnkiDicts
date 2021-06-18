class ExampleSentence {
  String jpSentenceId;
  String targetSentenceId;
  String jpSentence;
  String targetSentence;
  ExampleSentence(
      {this.jpSentence,
      this.targetSentence,
      this.jpSentenceId,
      this.targetSentenceId});

  Map<String, dynamic> toMap() {
    return {
      'jpSentenceId': jpSentenceId,
      'vnSentenceId': targetSentenceId,
      'jpSentence': jpSentence,
      'vnSentence': targetSentence,
    };
  }
}
