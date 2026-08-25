import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_entity.dart';

/// Firebase Auth implementation of [AuthRemoteDataSource].
class FirebaseAuthDataSource implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  UserEntity? _mapUser(fb.User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
    );
  }

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? true;

  @override
  String? get userEmail => _firebaseAuth.currentUser?.email;

  @override
  Stream<UserEntity?> watchAuthState() {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return _mapUser(credential.user)!;
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapUser(credential.user)!;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapUser(credential.user)!;
  }

  @override
  Future<UserEntity> linkAccountWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user currently signed in to link account.');
    }
    final credential = fb.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final userCredential = await user.linkWithCredential(credential);
    return _mapUser(userCredential.user)!;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
