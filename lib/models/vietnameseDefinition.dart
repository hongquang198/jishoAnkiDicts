class VietnameseDefinition {
  final String word;
  final String definition;

  const VietnameseDefinition({
    this.word = '',
    this.definition = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'definition': definition,
    };
  }
}
