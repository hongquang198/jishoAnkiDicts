class VietnameseDefinition {
  final String word;
  final String definition;

  VietnameseDefinition({
    this.word,
    this.definition,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'definition': definition,
    };
  }
}
