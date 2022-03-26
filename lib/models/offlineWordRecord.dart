class OfflineWordRecord {
  String slug; //
  int isCommon; //
  String tags; //
  String jlpt; //
  String word; //
  String reading; //
  String senses; //
  String vietnameseDefinition; //
  // Date
  int added;
  int firstReview;
  int lastReview;
  int due;
  // Duration
  int interval;
  double ease;
  int reviews;
  int lapses;

  double averageTimeMinute;
  double totalTimeMinute;
  String cardType;
  String noteType;
  String deck;

  OfflineWordRecord(
      {this.slug,
      this.isCommon,
      this.tags,
      this.jlpt,
      this.word,
      this.reading,
      this.senses,
      this.vietnameseDefinition,
      this.added,
      this.firstReview,
      this.lastReview,
      this.due,
      this.interval,
      this.ease,
      this.reviews,
      this.lapses,
      this.averageTimeMinute,
      this.totalTimeMinute,
      this.cardType,
      this.noteType,
      this.deck});

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'is_common': isCommon,
      'tags': tags,
      'jlpt': jlpt,
      'word': word,
      'reading': reading,
      'senses': senses,
      'vietnamese_definition': vietnameseDefinition,
      'added': added,
      'firstReview': firstReview,
      'lastReview': lastReview,
      'due': due,
      'interval': interval,
      'ease': ease,
      'reviews': reviews,
      'lapses': lapses,
      'averageTimeMinute': averageTimeMinute,
      'totalTimeMinute': totalTimeMinute,
      'cardType': cardType,
      'noteType': noteType,
      'deck': deck,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'OfflineWordRecord{slug: $slug, is_common: $isCommon, tags: $tags, '
        'jlpt: $jlpt, word: $word, reading: $reading, senses: $senses,'
        'vietnamese_definition: $vietnameseDefinition, added: $added, firstReview: $firstReview,'
        'lastReview: $lastReview, due: $due, interval: $interval, ease: $ease, reviews: $reviews, '
        'lapses: $lapses, averageTimeMinute: $averageTimeMinute, totalTimeMinute: $totalTimeMinute, '
        'cardType: $cardType, noteType: $noteType, deck: $deck}';
  }
}
