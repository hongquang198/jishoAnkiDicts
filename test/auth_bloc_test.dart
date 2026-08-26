import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_entity.dart';
import 'package:jisho_anki/features/auth/bloc/auth_bloc.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _authStream =
      StreamController<UserEntity?>.broadcast();

  FakeAuthRemoteDataSource({UserEntity? initialUser}) : _currentUser = initialUser;

  @override
  String? get currentUserId => _currentUser?.uid;

  @override
  bool get isAnonymous => _currentUser?.isAnonymous ?? true;

  @override
  String? get userEmail => _currentUser?.email;

  @override
  Stream<UserEntity?> watchAuthState() => _authStream.stream;

  @override
  Future<UserEntity> signInAnonymously() async {
    _currentUser = const UserEntity(
      uid: 'anon_123',
      isAnonymous: true,
    );
    _authStream.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _currentUser = UserEntity(
      uid: 'user_123',
      email: email,
      isAnonymous: false,
    );
    _authStream.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> linkAccountWithEmail({
    required String email,
    required String password,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user signed in');
    }
    _currentUser = UserEntity(
      uid: _currentUser!.uid,
      email: email,
      isAnonymous: false,
    );
    _authStream.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    _currentUser = const UserEntity(
      uid: 'google_123',
      email: 'google@example.com',
      isAnonymous: false,
    );
    _authStream.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> linkAccountWithGoogle() async {
    if (_currentUser == null) {
      throw Exception('No user signed in');
    }
    _currentUser = UserEntity(
      uid: _currentUser!.uid,
      email: 'google_linked@example.com',
      isAnonymous: false,
    );
    _authStream.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStream.add(null);
  }

  void dispose() {
    _authStream.close();
  }
}

void main() {
  group('AuthBloc Unit Tests', () {
    late FakeAuthRemoteDataSource fakeAuthDataSource;
    late AuthBloc authBloc;

    setUp(() {
      fakeAuthDataSource = FakeAuthRemoteDataSource();
      authBloc = AuthBloc(authDataSource: fakeAuthDataSource);
    });

    tearDown(() {
      authBloc.close();
      fakeAuthDataSource.dispose();
    });

    test('CheckAuthStatus triggers anonymous sign in when no user exists', () async {
      expect(authBloc.state, equals(AuthInitial()));

      authBloc.add(CheckAuthStatus());
      await pumpEventQueue();

      expect(authBloc.state, isA<Authenticated>());
      final state = authBloc.state as Authenticated;
      expect(state.user.isAnonymous, isTrue);
      expect(state.user.uid, equals('anon_123'));
    });

    test('SignInRequested successfully signs in with email', () async {
      authBloc.add(const SignInRequested(email: 'test@example.com', password: 'password123'));
      await pumpEventQueue();

      expect(authBloc.state, isA<Authenticated>());
      final state = authBloc.state as Authenticated;
      expect(state.user.email, equals('test@example.com'));
      expect(state.user.isAnonymous, isFalse);
    });

    test('LinkAccountRequested upgrades anonymous user to registered email account', () async {
      await fakeAuthDataSource.signInAnonymously();
      expect(fakeAuthDataSource.isAnonymous, isTrue);

      authBloc.add(const LinkAccountRequested(email: 'linked@example.com', password: 'password123'));
      await pumpEventQueue();

      expect(authBloc.state, isA<Authenticated>());
      final state = authBloc.state as Authenticated;
      expect(state.user.email, equals('linked@example.com'));
      expect(state.user.isAnonymous, isFalse);
      expect(state.user.uid, equals('anon_123'));
    });
  });
}
