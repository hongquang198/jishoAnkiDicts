import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_data.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:unofficial_jisho_api/api.dart';

/// Comprehensive entity representing a user's word card (for bookmarks and SRS reviews).
class WordCard extends Equatable {
  /// Unique identifier (usually the word or slug).
  final String id;

  /// Main Kanji/Kana representation.
  final String word;

  /// Jisho slug.
  final String slug;

  /// Furigana / Kana reading.
  final String reading;

  /// Is common word tag (1 = true, 0 = false).
  final int isCommon;

  /// List of category tags.
  final List<String> tags;

  /// JLPT levels (e.g. ['jlpt-n3']).
  final List<String> jlpt;

  /// Definitions and senses from Jisho.
  final List<JishoWordSense> senses;

  /// Vietnamese definition text, if available.
  final String vietnameseDefinition;

  /// Bookmark status.
  final bool isFavorite;

  /// Spaced repetition data (null if not in review deck).
  final SrsData? srsData;

  /// Timestamp when created.
  final int addedAt;

  /// Timestamp when last updated (for LWW sync).
  final int updatedAt;

  /// Sync flag for local-first synchronization.
  final bool isSynced;

  /// Deck name (defaults to 'default').
  final String deck;

  /// AI tutor comment and nuances.
  final String? aiTutorComment;

  /// AI memory tip and mnemonics.
  final String? aiMemoryTip;

  const WordCard({
    required this.id,
    required this.word,
    this.slug = '',
    this.reading = '',
    this.isCommon = 0,
    this.tags = const [],
    this.jlpt = const [],
    this.senses = const [],
    this.vietnameseDefinition = '',
    this.isFavorite = false,
    this.srsData,
    required this.addedAt,
    required this.updatedAt,
    this.isSynced = false,
    this.deck = 'default',
    this.aiTutorComment,
    this.aiMemoryTip,
  });

  /// Primary display term for the word.
  String get japaneseWord {
    if (word.isNotEmpty) return word;
    if (slug.isNotEmpty) return slug;
    return reading;
  }

  /// Whether the card is enrolled in the review deck.
  bool get isInReview => srsData != null;

  WordCard copyWith({
    String? id,
    String? word,
    String? slug,
    String? reading,
    int? isCommon,
    List<String>? tags,
    List<String>? jlpt,
    List<JishoWordSense>? senses,
    String? vietnameseDefinition,
    bool? isFavorite,
    SrsData? srsData,
    bool clearSrsData = false,
    int? addedAt,
    int? updatedAt,
    bool? isSynced,
    String? deck,
    String? aiTutorComment,
    String? aiMemoryTip,
  }) {
    return WordCard(
      id: id ?? this.id,
      word: word ?? this.word,
      slug: slug ?? this.slug,
      reading: reading ?? this.reading,
      isCommon: isCommon ?? this.isCommon,
      tags: tags ?? this.tags,
      jlpt: jlpt ?? this.jlpt,
      senses: senses ?? this.senses,
      vietnameseDefinition:
          vietnameseDefinition ?? this.vietnameseDefinition,
      isFavorite: isFavorite ?? this.isFavorite,
      srsData: clearSrsData ? null : (srsData ?? this.srsData),
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      deck: deck ?? this.deck,
      aiTutorComment: aiTutorComment ?? this.aiTutorComment,
      aiMemoryTip: aiMemoryTip ?? this.aiMemoryTip,
    );
  }

  /// Convert to [JishoDefinition] for UI reuse.
  JishoDefinition get toJishoDefinition => JishoDefinition(
        slug: slug.isNotEmpty ? slug : word,
        isCommon: isCommon == 1,
        tags: tags,
        jlpt: jlpt,
        word: word,
        reading: reading,
        senses: senses,
      );

  /// Factory to construct from a [JishoDefinition].
  factory WordCard.fromJishoDefinition({
    required JishoDefinition jisho,
    String vietnameseDefinition = '',
    bool isFavorite = false,
    SrsData? srsData,
    int? timestamp,
    String? aiTutorComment,
    String? aiMemoryTip,
  }) {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final primaryWord =
        (jisho.word != null && jisho.word!.isNotEmpty) ? jisho.word! : jisho.slug;
    return WordCard(
      id: primaryWord,
      word: jisho.word ?? '',
      slug: jisho.slug,
      reading: jisho.reading ?? '',
      isCommon: jisho.isCommon ? 1 : 0,
      tags: jisho.tags,
      jlpt: jisho.jlpt,
      senses: jisho.senses,
      vietnameseDefinition: vietnameseDefinition,
      isFavorite: isFavorite,
      srsData: srsData,
      addedAt: now,
      updatedAt: now,
      isSynced: false,
      aiTutorComment: aiTutorComment,
      aiMemoryTip: aiMemoryTip,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'slug': slug,
      'reading': reading,
      'is_common': isCommon,
      'tags': json.encode(tags),
      'jlpt': json.encode(jlpt),
      'senses': json.encode(senses.map((x) => x.toJson()).toList()),
      'vietnamese_definition': vietnameseDefinition,
      'is_favorite': isFavorite ? 1 : 0,
      'srs_data': srsData != null ? json.encode(srsData!.toMap()) : null,
      'added_at': addedAt,
      'updated_at': updatedAt,
      'is_synced': isSynced ? 1 : 0,
      'deck': deck,
      'ai_tutor_comment': aiTutorComment,
      'ai_memory_tip': aiMemoryTip,
    };
  }

  factory WordCard.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic raw) {
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

    SrsData? parseSrsData(dynamic raw) {
      if (raw == null) return null;
      try {
        final decoded = raw is String ? json.decode(raw) : raw;
        if (decoded is Map<String, dynamic>) {
          return SrsData.fromMap(decoded);
        }
      } catch (_) {}
      return null;
    }

    return WordCard(
      id: map['id'] as String? ?? (map['word'] as String? ?? ''),
      word: map['word'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      reading: map['reading'] as String? ?? '',
      isCommon: (map['is_common'] as num?)?.toInt() ?? 0,
      tags: parseList(map['tags']),
      jlpt: parseList(map['jlpt']),
      senses: parseSenses(map['senses']),
      vietnameseDefinition: map['vietnamese_definition'] as String? ?? '',
      isFavorite: map['is_favorite'] == 1 || map['is_favorite'] == true,
      srsData: parseSrsData(map['srs_data']),
      addedAt: (map['added_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
      deck: map['deck'] as String? ?? 'default',
      aiTutorComment: map['ai_tutor_comment'] as String?,
      aiMemoryTip: map['ai_memory_tip'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        word,
        slug,
        reading,
        isCommon,
        tags,
        jlpt,
        senses,
        vietnameseDefinition,
        isFavorite,
        srsData,
        addedAt,
        updatedAt,
        isSynced,
        deck,
        aiTutorComment,
        aiMemoryTip,
      ];
}
