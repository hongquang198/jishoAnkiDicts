class ExampleSentence {
  String? jpSentenceId;
  String? targetSentenceId;
  String? jpSentence;
  String? targetSentence;
  ExampleSentence(
      {required this.jpSentence,
      required this.targetSentence,
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
