// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:unofficial_jisho_api/api.dart';

class OfflineWordRecord {
  final String slug; //
  final int isCommon; //
  final List<String> tags; //
  final List<String> jlpt; //
  final String word; //
  final String reading; //
  final List<JishoWordSense> senses; //
  final String vietnameseDefinition; //
  // Date
  final int added;
  final int? firstReview;
  final int? lastReview;
  final int due;
  // Duration
  final int interval;
  final double ease;
  final int reviews;
  final int lapses;

  final double averageTimeMinute;
  final double totalTimeMinute;
  final String cardType;
  final String noteType;
  final String deck;

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
      this.tags = const [],
      this.jlpt = const [],
      this.word = '',
      this.reading = '',
      this.senses = const [],
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slug': slug,
      'is_common': isCommon,
      'tags': json.encode(tags),
      'jlpt': json.encode(jlpt),
      'word': word,
      'reading': reading,
      'senses': json.encode(senses.map((x) => x.toJson()).toList()),
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

  factory OfflineWordRecord.fromMap(Map<String, dynamic> map) {
    return OfflineWordRecord(
      slug: map['slug'] as String,
      isCommon: map['is_common'] as int,
      tags: List<String>.from((json.decode(map['tags']))),
      jlpt: List<String>.from((json.decode(map['jlpt']))),
      word: map['word'] as String,
      reading: map['reading'] as String,
      senses: List<JishoWordSense>.from(
        (json.decode(map['senses']) as List<dynamic>).map<JishoWordSense>(
          (x) => JishoWordSense.fromJson(x as Map<String, dynamic>),
        ),
      ),
      vietnameseDefinition: map['vietnamese_definition'] as String,
      added: map['added'] as int,
      firstReview:
          map['firstReview'] != null ? map['firstReview'] as int : null,
      lastReview: map['lastReview'] != null ? map['lastReview'] as int : null,
      due: map['due'] as int,
      interval: map['interval'] as int,
      ease: map['ease'] as double,
      reviews: map['reviews'] as int,
      lapses: map['lapses'] as int,
      averageTimeMinute: map['averageTimeMinute'] as double,
      totalTimeMinute: map['totalTimeMinute'] as double,
      cardType: map['cardType'] as String,
      noteType: map['noteType'] as String,
      deck: map['deck'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfflineWordRecord.fromJson(String source) =>
      OfflineWordRecord.fromMap(json.decode(source) as Map<String, dynamic>);

  OfflineWordRecord copyWith({
    String? slug,
    int? isCommon,
    List<String>? tags,
    List<String>? jlpt,
    String? word,
    String? reading,
    List<JishoWordSense>? senses,
    String? vietnameseDefinition,
    int? added,
    int? firstReview,
    int? lastReview,
    int? due,
    int? interval,
    double? ease,
    int? reviews,
    int? lapses,
    double? averageTimeMinute,
    double? totalTimeMinute,
    String? cardType,
    String? noteType,
    String? deck,
  }) {
    return OfflineWordRecord(
      slug: slug ?? this.slug,
      isCommon: isCommon ?? this.isCommon,
      tags: tags ?? this.tags,
      jlpt: jlpt ?? this.jlpt,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      senses: senses ?? this.senses,
      vietnameseDefinition: vietnameseDefinition ?? this.vietnameseDefinition,
      added: added ?? this.added,
      firstReview: firstReview ?? this.firstReview,
      lastReview: lastReview ?? this.lastReview,
      due: due ?? this.due,
      interval: interval ?? this.interval,
      ease: ease ?? this.ease,
      reviews: reviews ?? this.reviews,
      lapses: lapses ?? this.lapses,
      averageTimeMinute: averageTimeMinute ?? this.averageTimeMinute,
      totalTimeMinute: totalTimeMinute ?? this.totalTimeMinute,
      cardType: cardType ?? this.cardType,
      noteType: noteType ?? this.noteType,
      deck: deck ?? this.deck,
    );
  }
}
