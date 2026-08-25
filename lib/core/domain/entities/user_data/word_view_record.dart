import 'package:equatable/equatable.dart';

/// Tracks total view count and timestamps for a specific lookup term.
class WordViewRecord extends Equatable {
  final String word;
  final int viewCount;
  final int firstViewedAt;
  final int lastViewedAt;
  final bool isSynced;

  const WordViewRecord({
    required this.word,
    this.viewCount = 1,
    required this.firstViewedAt,
    required this.lastViewedAt,
    this.isSynced = false,
  });

  WordViewRecord copyWith({
    String? word,
    int? viewCount,
    int? firstViewedAt,
    int? lastViewedAt,
    bool? isSynced,
  }) {
    return WordViewRecord(
      word: word ?? this.word,
      viewCount: viewCount ?? this.viewCount,
      firstViewedAt: firstViewedAt ?? this.firstViewedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'view_count': viewCount,
      'first_viewed_at': firstViewedAt,
      'last_viewed_at': lastViewedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory WordViewRecord.fromMap(Map<String, dynamic> map) {
    return WordViewRecord(
      word: map['word'] as String,
      viewCount: (map['view_count'] as num?)?.toInt() ?? 1,
      firstViewedAt: (map['first_viewed_at'] as num?)?.toInt() ?? 0,
      lastViewedAt: (map['last_viewed_at'] as num?)?.toInt() ?? 0,
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  @override
  List<Object?> get props => [word, viewCount, firstViewedAt, lastViewedAt, isSynced];
}
