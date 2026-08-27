import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jisho_anki/core/data/datasources/local_user_data_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// SQLite implementation of [LocalUserDataDataSource] storing user data in `user_data.db`.
class UserLocalDataSourceImpl implements LocalUserDataDataSource {
  final String dbName;
  Database? _db;

  UserLocalDataSourceImpl({this.dbName = 'user_data.db'});

  /// Constructor for testing with an in-memory or custom database.
  UserLocalDataSourceImpl.withDatabase(Database db)
      : dbName = '',
        _db = db;

  Database get database {
    if (_db == null) {
      throw StateError('UserLocalDataSourceImpl is not initialized. Call init() first.');
    }
    return _db!;
  }

  @override
  Future<void> init() async {
    if (_db != null) return;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE user_cards ADD COLUMN ai_tutor_comment TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE user_cards ADD COLUMN ai_memory_tip TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE lookup_history ADD COLUMN ai_tutor_comment TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE lookup_history ADD COLUMN ai_memory_tip TEXT;');
      } catch (_) {}
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_cards (
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL,
        slug TEXT,
        reading TEXT,
        is_common INTEGER DEFAULT 0,
        tags TEXT,
        jlpt TEXT,
        senses TEXT,
        vietnamese_definition TEXT,
        is_favorite INTEGER DEFAULT 0,
        srs_data TEXT,
        added_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        deck TEXT DEFAULT 'default',
        ai_tutor_comment TEXT,
        ai_memory_tip TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE word_views (
        word TEXT PRIMARY KEY,
        view_count INTEGER DEFAULT 1,
        first_viewed_at INTEGER NOT NULL,
        last_viewed_at INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE lookup_history (
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL,
        slug TEXT,
        reading TEXT,
        is_common INTEGER DEFAULT 0,
        tags TEXT,
        jlpt TEXT,
        senses TEXT,
        vietnamese_definition TEXT,
        is_favorite INTEGER DEFAULT 0,
        srs_data TEXT,
        added_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        deck TEXT DEFAULT 'default',
        ai_tutor_comment TEXT,
        ai_memory_tip TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE review_logs (
        id TEXT PRIMARY KEY,
        card_id TEXT NOT NULL,
        rating TEXT NOT NULL,
        duration_ms INTEGER DEFAULT 0,
        reviewed_at INTEGER NOT NULL,
        prev_interval_ms INTEGER DEFAULT 0,
        new_interval_ms INTEGER DEFAULT 0,
        prev_ease REAL DEFAULT 2.5,
        new_ease REAL DEFAULT 2.5,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_user_cards_favorite ON user_cards (is_favorite);');
    await db.execute(
        'CREATE INDEX idx_lookup_history_added ON lookup_history (added_at DESC);');
    await db.execute(
        'CREATE INDEX idx_review_logs_reviewed ON review_logs (reviewed_at DESC);');
  }

  // --- Cards ---

  @override
  Future<void> upsertCard(WordCard card) async {
    await database.insert(
      'user_cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertBatchCards(List<WordCard> cards) async {
    final batch = database.batch();
    for (final card in cards) {
      batch.insert(
        'user_cards',
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<WordCard?> getCard(String id) async {
    final maps = await database.query(
      'user_cards',
      where: 'id = ? OR word = ? OR slug = ?',
      whereArgs: [id, id, id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WordCard.fromMap(maps.first);
  }

  @override
  Future<List<WordCard>> getAllCards() async {
    final maps = await database.query('user_cards', orderBy: 'updated_at DESC');
    return maps.map((m) => WordCard.fromMap(m)).toList();
  }

  @override
  Future<List<WordCard>> getFavorites() async {
    final maps = await database.query(
      'user_cards',
      where: 'is_favorite = 1',
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => WordCard.fromMap(m)).toList();
  }

  @override
  Future<List<WordCard>> getReviewCards() async {
    final maps = await database.query(
      'user_cards',
      where: 'srs_data IS NOT NULL',
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => WordCard.fromMap(m)).toList();
  }

  @override
  Future<void> deleteCard(String id) async {
    await database.delete(
      'user_cards',
      where: 'id = ? OR word = ? OR slug = ?',
      whereArgs: [id, id, id],
    );
  }

  // --- Word Views ---

  @override
  Future<void> recordView(String word, {int? timestamp}) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final existing = await getViewRecord(word);
    if (existing == null) {
      final record = WordViewRecord(
        word: word,
        viewCount: 1,
        firstViewedAt: now,
        lastViewedAt: now,
        isSynced: false,
      );
      await database.insert('word_views', record.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      final updated = existing.copyWith(
        viewCount: existing.viewCount + 1,
        lastViewedAt: now,
        isSynced: false,
      );
      await database.update(
        'word_views',
        updated.toMap(),
        where: 'word = ?',
        whereArgs: [word],
      );
    }
  }

  @override
  Future<WordViewRecord?> getViewRecord(String word) async {
    final maps = await database.query(
      'word_views',
      where: 'word = ?',
      whereArgs: [word],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WordViewRecord.fromMap(maps.first);
  }

  @override
  Future<List<WordViewRecord>> getAllViewRecords() async {
    final maps = await database.query('word_views');
    return maps.map((m) => WordViewRecord.fromMap(m)).toList();
  }

  // --- History ---

  @override
  Future<void> addHistory(WordCard card) async {
    // Delete previous instance if any to ensure deduplication
    await database.delete(
      'lookup_history',
      where: 'id = ? OR word = ? OR slug = ?',
      whereArgs: [card.id, card.word, card.slug],
    );
    await database.insert(
      'lookup_history',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<WordCard>> getHistory({int limit = 100}) async {
    final maps = await database.query(
      'lookup_history',
      orderBy: 'added_at DESC',
      limit: limit,
    );
    return maps.map((m) => WordCard.fromMap(m)).toList();
  }

  @override
  Future<void> deleteHistory(String id) async {
    await database.delete(
      'lookup_history',
      where: 'id = ? OR word = ? OR slug = ?',
      whereArgs: [id, id, id],
    );
  }

  @override
  Future<void> clearHistory() async {
    await database.delete('lookup_history');
  }

  // --- Review Logs ---

  @override
  Future<void> insertReviewLog(ReviewLog log) async {
    await database.insert(
      'review_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteReviewLog(String logId) async {
    await database.delete(
      'review_logs',
      where: 'id = ?',
      whereArgs: [logId],
    );
  }

  @override
  Future<List<ReviewLog>> getReviewLogs({int? sinceTimestamp}) async {
    if (sinceTimestamp != null) {
      final maps = await database.query(
        'review_logs',
        where: 'reviewed_at >= ?',
        whereArgs: [sinceTimestamp],
        orderBy: 'reviewed_at DESC',
      );
      return maps.map((m) => ReviewLog.fromMap(m)).toList();
    } else {
      final maps = await database.query(
        'review_logs',
        orderBy: 'reviewed_at DESC',
      );
      return maps.map((m) => ReviewLog.fromMap(m)).toList();
    }
  }

  // --- Sync Helpers ---

  @override
  Future<List<WordCard>> getUnsyncedCards() async {
    final maps = await database.query(
      'user_cards',
      where: 'is_synced = 0',
    );
    return maps.map((m) => WordCard.fromMap(m)).toList();
  }

  @override
  Future<List<WordViewRecord>> getUnsyncedViews() async {
    final maps = await database.query(
      'word_views',
      where: 'is_synced = 0',
    );
    return maps.map((m) => WordViewRecord.fromMap(m)).toList();
  }

  @override
  Future<List<ReviewLog>> getUnsyncedReviewLogs() async {
    final maps = await database.query(
      'review_logs',
      where: 'is_synced = 0',
    );
    return maps.map((m) => ReviewLog.fromMap(m)).toList();
  }

  @override
  Future<void> markCardsSynced(List<String> cardIds) async {
    if (cardIds.isEmpty) return;
    final batch = database.batch();
    for (final id in cardIds) {
      batch.update(
        'user_cards',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> markViewsSynced(List<String> words) async {
    if (words.isEmpty) return;
    final batch = database.batch();
    for (final word in words) {
      batch.update(
        'word_views',
        {'is_synced': 1},
        where: 'word = ?',
        whereArgs: [word],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> markReviewLogsSynced(List<String> logIds) async {
    if (logIds.isEmpty) return;
    final batch = database.batch();
    for (final id in logIds) {
      batch.update(
        'review_logs',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }
}
