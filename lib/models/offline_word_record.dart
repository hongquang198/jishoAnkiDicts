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
  int? firstReview;
  int? lastReview;
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

  String get japaneseWord {
    if (word.isNotEmpty) {
      return word;
    } else if (slug.isNotEmpty) {
      return slug;
    }
    return reading;
  }

  OfflineWordRecord(
      {required this.slug,
      this.isCommon = -1,
      this.tags = '',
      this.jlpt = '',
      this.word = '',
      this.reading = '',
      this.senses = '',
      this.vietnameseDefinition = '',
      this.added = -1,
      this.firstReview,
      this.lastReview,
      this.due = -1,
      this.interval = -1,
      this.ease = -1,
      this.reviews = -1,
      this.lapses = -1,
      this.averageTimeMinute = -1,
      this.totalTimeMinute = -1,
      this.cardType = '',
      this.noteType = '',
      this.deck = ''});

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
