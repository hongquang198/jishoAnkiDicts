# Design Specification: Firebase Auth & Cloud Firestore Adapter

## 1. System Architecture

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│         (AuthBloc, SettingsScreen, AuthDialog)         │
└───────────────────────────┬────────────────────────────┘
                            │ (Events & States)
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│   (UserEntity, AuthRepository, UserDataRepository)     │
└───────────────────────────┬────────────────────────────┘
                            │ (Contracts)
┌───────────────────────────▼────────────────────────────┐
│                       Data Layer                       │
│  ┌───────────────────────┐   ┌──────────────────────┐  │
│  │ FirebaseAuthDataSource│   │ FirebaseUserData-    │  │
│  │ (Auth & Credentials)  │   │ DataSource           │  │
│  └───────────┬───────────┘   └──────────┬───────────┘  │
└──────────────┼──────────────────────────┼──────────────┘
               │                          │
┌──────────────▼──────────────────────────▼──────────────┐
│                    Firebase Backend                    │
│   (Firebase Auth)         (Cloud Firestore Database)   │
└────────────────────────────────────────────────────────┘
```

## 2. Firestore Document Schemas

### 2.1 Cards Document: `/users/{uid}/cards/{cardId}`
```json
{
  "id": "猫",
  "word": "猫",
  "slug": "猫",
  "reading": "ねこ",
  "is_common": 1,
  "tags": ["common word"],
  "jlpt": ["jlpt-n5"],
  "senses": [],
  "vietnamese_definition": "con mèo",
  "is_favorite": true,
  "srs_data": {
    "stage": "review",
    "due_at": 1724600000000,
    "interval_ms": 864000000,
    "ease_factor": 2.5,
    "step_index": 0,
    "reviews": 4,
    "lapses": 0,
    "first_reviewed_at": 1724000000000,
    "last_reviewed_at": 1724500000000,
    "is_leech": false
  },
  "added_at": 1724000000000,
  "updated_at": 1724500000000,
  "deck": "default"
}
```

### 2.2 Word View Document: `/users/{uid}/views/{word}`
```json
{
  "word": "猫",
  "view_count": 12,
  "first_viewed_at": 1724000000000,
  "last_viewed_at": 1724500000000
}
```

### 2.3 Review Log Document: `/users/{uid}/review_logs/{logId}`
```json
{
  "id": "log_1724500000000_猫",
  "card_id": "猫",
  "rating": "good",
  "duration_ms": 3200,
  "reviewed_at": 1724500000000,
  "prev_interval_ms": 86400000,
  "new_interval_ms": 216000000,
  "prev_ease": 2.5,
  "new_ease": 2.5
}
```

## 3. Account Linking & Authentication Logic

```dart
abstract class AuthRemoteDataSource {
  String? get currentUserId;
  bool get isAnonymous;
  String? get userEmail;
  Stream<UserEntity?> watchAuthState();

  Future<UserEntity> signInAnonymously();
  Future<UserEntity> signInWithEmail({required String email, required String password});
  Future<UserEntity> linkAccountWithEmail({required String email, required String password});
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> linkAccountWithGoogle();
  Future<void> signOut();
}
```

Note: there is deliberately no `signUpWithEmail`. Registration is expressed
as *linking a credential onto the anonymous guest session* (`linkWithCredential`),
which creates the account while preserving the guest `uid` and its synced data.

### UX Entry Points (two flows)

| Button | Dialog mode | Behavior |
|---|---|---|
| "Create Account & Sync" | linking | New email/Google → registers & keeps guest uid; existing credentials → silently falls back to sign-in (uid switches, guest cloud data is orphaned — accepted trade-off) |
| "Sign In to Existing Account" / "Switch Account" | sign-in | Replaces the session entirely |

### Account Linking Implementation Pattern
```dart
@override
Future<UserEntity> linkAccountWithEmail({
  required String email,
  required String password,
}) async {
  var user = _firebaseAuth.currentUser;
  if (user == null) {
    final anon = await _firebaseAuth.signInAnonymously();
    user = anon.user;
  }
  final credential = fb.EmailAuthProvider.credential(email: email, password: password);
  try {
    final userCredential = await user!.linkWithCredential(credential);
    return _mapFirebaseUser(userCredential.user!);
  } catch (e) {
    // Existing account: degrade gracefully to plain sign-in.
    // The uid switches to the existing account; guest data does NOT migrate.
    if (user?.isAnonymous == true &&
        (e.toString().contains('credential-already-in-use') ||
            e.toString().contains('email-already-in-use'))) {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(userCredential.user!);
    }
    rethrow;
  }
}
```

`linkAccountWithGoogle()` follows the same pattern with a
`GoogleAuthProvider.credential(idToken: ...)` and falls back on
`credential-already-in-use`.

## 4. `AuthBloc` State Machine

- **Events**:
  - `CheckAuthStatus`
  - `SignInRequested(email, password)`
  - `LinkAccountRequested(email, password)`
  - `SignInWithGoogleRequested`
  - `LinkAccountWithGoogleRequested`
  - `SignOutRequested`
- **States**:
  - `AuthInitial`
  - `AuthLoading`
  - `Authenticated(UserEntity user)`
  - `Unauthenticated`
  - `AuthError(String message)`
