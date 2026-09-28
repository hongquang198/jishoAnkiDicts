import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

// REST implementation of [AuthRemoteDataSource] against the custom backend.
// Owns identity: mints JWTs via /auth/*, persists them, attaches them to calls.
// Token + uid live in SharedPreferences so sessions survive app restarts.
class RestAuthDataSource implements AuthRemoteDataSource {
  static const _kUserId = 'rest_user_id';
  static const _kToken = 'rest_access_token';
  static const _kEmail = 'rest_email';
  static const _kIsAnon = 'rest_is_anonymous';

  final Dio _dio;
  final SharedPreferences _prefs;
  final StreamController<UserEntity?> _authController =
      StreamController<UserEntity?>.broadcast();

  UserEntity? _current;

  RestAuthDataSource({
    // --dart-define=API_BASE_URL=... overrides this. Default targets the
    // Android emulator's host loopback; iOS sim / desktop use localhost:8000.
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
    required SharedPreferences prefs,
    Dio? dio,
  })  : _prefs = prefs,
        _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    // Restore last session (if any) so restarts don't log the user out.
    final uid = _prefs.getString(_kUserId);
    if (uid != null) {
      _current = UserEntity(
        uid: uid,
        email: _prefs.getString(_kEmail),
        isAnonymous: _prefs.getBool(_kIsAnon) ?? true,
      );
    }
  }

  // Current JWT for authenticated calls (consumed by RestUserDataDataSource).
  String? get accessToken => _prefs.getString(_kToken);

  Map<String, String> get authHeader {
    final token = accessToken;
    return token == null ? {} : {'Authorization': 'Bearer $token'};
  }

  @override
  String? get currentUserId => _current?.uid;

  @override
  bool get isAnonymous => _current?.isAnonymous ?? true;

  @override
  String? get userEmail => _current?.email;

  @override
  Stream<UserEntity?> watchAuthState() async* {
    yield _current; // immediate value, then live updates (mirrors Firebase's first event)
    yield* _authController.stream;
  }

  Future<UserEntity> _saveSession(
    Map<String, dynamic> json, {
    required bool isAnonymous,
    String? email,
  }) async {
    final user = UserEntity(
      uid: json['user_id'] as String,
      email: email ?? json['email'] as String?,
      isAnonymous: isAnonymous,
    );
    await _prefs.setString(_kUserId, user.uid);
    await _prefs.setString(_kToken, json['access_token'] as String);
    if (user.email != null) await _prefs.setString(_kEmail, user.email!);
    await _prefs.setBool(_kIsAnon, isAnonymous);
    _current = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    final res = await _dio.post('/auth/anon');
    return _saveSession(res.data as Map<String, dynamic>, isAnonymous: true);
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _dio
        .post('/auth/login', data: {'email': email, 'password': password});
    return _saveSession(res.data as Map<String, dynamic>,
        isAnonymous: false, email: email);
  }

  @override
  Future<UserEntity> linkAccountWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/link-email',
        data: {'email': email, 'password': password},
        options: Options(headers: authHeader));
    return _saveSession(res.data as Map<String, dynamic>,
        isAnonymous: false, email: email);
  }

  // Google arrives with P2's /auth/link-google (currently 501 server-side).
  @override
  Future<UserEntity> signInWithGoogle() =>
      throw UnimplementedError('REST Google sign-in needs P2');

  @override
  Future<UserEntity> linkAccountWithGoogle() =>
      throw UnimplementedError('REST Google link needs P2');

  @override
  Future<void> signOut() async {
    await _prefs.remove(_kUserId);
    await _prefs.remove(_kToken);
    await _prefs.remove(_kEmail);
    await _prefs.setBool(_kIsAnon, true);
    _current = null;
    _authController.add(null);
  }
}
