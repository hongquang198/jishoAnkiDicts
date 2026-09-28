import 'package:dio/dio.dart';
import 'package:jisho_anki/core/data/datasources/remote_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/rest_auth_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_settings_entity.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

// REST implementation of [RemoteUserDataDataSource] against the custom backend.
// Each method is a 1:1 translation of the Firebase impl's Firestore call into
// the HTTP sync protocol: bulk-PUT to push, ?since= GET to pull, DELETE to drop.
// Pydantic ignores the extra toMap() keys server-side; fromMap() defaults
// cover the minimal pull responses. Identity + tokens come from [RestAuthDataSource].
class RestUserDataDataSource implements RemoteUserDataDataSource {
  final Dio _dio;
  final RestAuthDataSource _auth;

  RestUserDataDataSource({
    required RestAuthDataSource auth,
    Dio? dio,
    // Same default as RestAuthDataSource — one flag (--dart-define=API_BASE_URL)
    // steers both. An explicit Dio (e.g. in tests) wins.
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
  })  : _auth = auth,
        _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  Options get _authed => Options(headers: _auth.authHeader);

  @override
  String? get currentUserId => _auth.currentUserId;

  @override
  Stream<String?> watchUserId() =>
      _auth.watchAuthState().map((user) => user?.uid);

  @override
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  @override
  Future<void> pushCards(List<WordCard> cards) async {
    await _dio.put('/cards/bulk',
        data: {'cards': cards.map((c) => c.toMap()).toList()},
        options: _authed);
  }

  @override
  Future<List<WordCard>> pullCardsUpdatedSince(int timestamp) async {
    final res = await _dio.get('/cards',
        queryParameters: {'since': timestamp}, options: _authed);
    final items = res.data['cards'] as List;
    return items
        .map((m) => WordCard.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  @override
  Future<void> pushViews(List<WordViewRecord> views) async {
    await _dio.put('/views/bulk',
        data: {'views': views.map((v) => v.toMap()).toList()},
        options: _authed);
  }

  @override
  Future<List<WordViewRecord>> pullViews() async {
    final res = await _dio.get('/views', options: _authed);
    final items = res.data['views'] as List;
    return items
        .map((m) => WordViewRecord.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  @override
  Future<void> pushReviewLogs(List<ReviewLog> logs) async {
    await _dio.put('/logs/bulk',
        data: {'logs': logs.map((l) => l.toMap()).toList()}, options: _authed);
  }

  @override
  Future<List<ReviewLog>> pullReviewLogs({int? sinceTimestamp}) async {
    final res = await _dio.get('/logs',
        // Null since = no filter (mirrors the optional Firestore where-clause).
        queryParameters:
            sinceTimestamp == null ? null : {'since': sinceTimestamp},
        options: _authed);
    final items = res.data['logs'] as List;
    return items
        .map((m) => ReviewLog.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  @override
  Future<void> deleteCard(String cardId) async {
    // Words travel in the path (e.g. /cards/猫) — encode non-ASCII segments.
    await _dio.delete('/cards/${Uri.encodeComponent(cardId)}',
        options: _authed);
  }

  @override
  Future<void> pushSettings(UserSettingsEntity settings) async {
    await _dio.put('/settings', data: settings.toMap(), options: _authed);
  }

  @override
  Future<UserSettingsEntity?> pullSettings() async {
    final res = await _dio.get('/settings', options: _authed);
    final raw = res.data['settings'];
    if (raw == null) return null; // never saved (mirrors missing config doc)
    return UserSettingsEntity.fromMap(Map<String, dynamic>.from(raw as Map));
  }
}
