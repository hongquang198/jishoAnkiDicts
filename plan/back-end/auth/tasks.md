# Implementation Tasks: Firebase Authentication & Cloud Firestore Integration

## Task 1: Add Firebase Dependencies & Initialization
- **Sub-task 1.1**: Add `firebase_core`, `firebase_auth`, and `cloud_firestore` packages to `pubspec.yaml`.
- **Sub-task 1.2**: Update `lib/main.dart` with `WidgetsFlutterBinding.ensureInitialized()` and `Firebase.initializeApp(...)` handling optional initialization when configuration files are present.

## Task 2: Auth Data Source, Entity & BLoC (TDD)
- **Sub-task 2.1**: Create `UserEntity` in `lib/core/domain/entities/user_data/user_entity.dart`.
- **Sub-task 2.2**: Define `AuthRemoteDataSource` contract in `lib/core/data/datasources/auth_remote_data_source.dart`.
- **Sub-task 2.3**: Implement `FirebaseAuthDataSource` handling anonymous login, email sign-in, registration, and `linkWithCredential` account linking in `lib/core/data/datasources/firebase_auth_data_source.dart`.
- **Sub-task 2.4**: Create `AuthBloc` in `lib/features/auth/bloc/auth_bloc.dart`.
- **Sub-task 2.5**: Write unit tests in `test/auth_bloc_test.dart`.

## Task 3: Real Firestore Integration in `FirebaseUserDataDataSource`
- **Sub-task 3.1**: Refactor `FirebaseUserDataDataSource` to perform real Cloud Firestore CRUD operations on `/users/{uid}/cards`, `/users/{uid}/views`, and `/users/{uid}/review_logs`.
- **Sub-task 3.2**: Implement Firestore batch writes for `pushCards`, `pushViews`, and `pushReviewLogs`.
- **Sub-task 3.3**: Implement Firestore real-time snapshot listeners for `pullCardsUpdatedSince` and `pullViews`.
- **Sub-task 3.4**: Write/update tests in `test/remote_user_data_source_test.dart`.

## Task 4: UI Integration in Settings Screen
- **Sub-task 4.1**: Create `AuthDialog` (`lib/features/settings/screens/widgets/auth_dialog.dart`) offering tabs for "Link Account", "Sign In", and "Register".
- **Sub-task 4.2**: Refactor `SettingsScreen` to display the "Account & Cloud Sync" section with current user status, User ID, and action buttons.
- **Sub-task 4.3**: Wire manual "Sync Now" button connected to `UserDataRepository.syncWithRemote()`.

## Task 5: Verification & Documentation
- **Sub-task 5.1**: Run `flutter analyze` to ensure zero diagnostics warnings.
- **Sub-task 5.2**: Run full test suite (`flutter test`) verifying all tests pass.
- **Sub-task 5.3**: Commit changes with git milestone commit message.
