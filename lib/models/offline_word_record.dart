import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'dart:convert';

class OfflineWordRecord {
  final String slug; //
  final int isCommon; //
  final List<String> tags; //
  final List<String> jlpt; //
  final String word; //
  final String reading; //
  final List<JishoWordSense> senses; //
  final String localizedGloss; //
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

  String get headword {
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
      this.localizedGloss = '',
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
        'localized_definition: $localizedGloss, added: $added, firstReview: $firstReview,'
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
      'localized_definition': localizedGloss,
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
    List<String> parseTags(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      try {
        final decoded = json.decode(raw.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    List<JishoWordSense> parseSenses(dynamic raw) {
      if (raw == null) return [];
      try {
        final decoded = raw is String ? json.decode(raw) : raw;
        if (decoded is List) {
          return decoded
              .map((x) => JishoWordSense.fromJson(x as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
      return [];
    }

    return OfflineWordRecord(
      slug: map['slug']?.toString() ?? '',
      isCommon: (map['is_common'] as num?)?.toInt() ?? -1,
      tags: parseTags(map['tags']),
      jlpt: parseTags(map['jlpt']),
      word: map['word']?.toString() ?? '',
      reading: map['reading']?.toString() ?? '',
      senses: parseSenses(map['senses']),
      // New asset uses `localized_definition`; fall back to the legacy
      // column name for on-device copies made before the rename.
      localizedGloss: (map['localized_definition'] ?? map['vietnamese_definition'])?.toString() ?? '',
      added: (map['added'] as num?)?.toInt() ?? -1,
      firstReview:
          map['firstReview'] != null ? (map['firstReview'] as num).toInt() : null,
      lastReview:
          map['lastReview'] != null ? (map['lastReview'] as num).toInt() : null,
      due: (map['due'] as num?)?.toInt() ?? -1,
      interval: (map['interval'] as num?)?.toInt() ?? -1,
      ease: (map['ease'] as num?)?.toDouble() ?? -1,
      reviews: (map['reviews'] as num?)?.toInt() ?? -1,
      lapses: (map['lapses'] as num?)?.toInt() ?? -1,
      averageTimeMinute:
          (map['averageTimeMinute'] as num?)?.toDouble() ?? -1,
      totalTimeMinute: (map['totalTimeMinute'] as num?)?.toDouble() ?? -1,
      cardType: map['cardType']?.toString() ?? '',
      noteType: map['noteType']?.toString() ?? '',
      deck: map['deck']?.toString() ?? '',
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
    String? localizedGloss,
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
      localizedGloss: localizedGloss ?? this.localizedGloss,
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

  JishoDefinition get toJishoDefinition => JishoDefinition(
        slug: slug,
        isCommon: isCommon == 1 ? true : false,
        tags: tags,
        jlpt: jlpt,
        word: word,
        reading: reading,
        senses: senses,
        isDbpedia: [],
        isJmdict: [],
        isJmnedict: [],
      );
}
