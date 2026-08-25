import 'package:jisho_anki/core/domain/entities/user_data/user_entity.dart';

/// Contract for remote authentication operations (Firebase Auth).
abstract class AuthRemoteDataSource {
  String? get currentUserId;
  bool get isAnonymous;
  String? get userEmail;
  Stream<UserEntity?> watchAuthState();

  Future<UserEntity> signInAnonymously();
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  });
  Future<UserEntity> linkAccountWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
}
