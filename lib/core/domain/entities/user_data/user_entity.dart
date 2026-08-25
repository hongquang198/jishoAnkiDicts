import 'package:equatable/equatable.dart';

/// Represents an authenticated user (guest or registered) in the system.
class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final bool isAnonymous;
  final String? displayName;

  const UserEntity({
    required this.uid,
    this.email,
    required this.isAnonymous,
    this.displayName,
  });

  @override
  List<Object?> get props => [uid, email, isAnonymous, displayName];
}
