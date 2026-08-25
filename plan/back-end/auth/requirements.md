# Requirements Specification: Firebase Authentication & Real Cloud Firestore Integration

## 1. Objective
To integrate real Firebase Authentication (supporting automatic zero-friction Anonymous Guest sessions with optional Email/Password Registration & Account Linking) and connect Cloud Firestore into `FirebaseUserDataDataSource` for multi-device real-time sync while preserving 100% of local offline study data.

## 2. Core Functional Requirements

### 2.1 Automatic Anonymous Authentication
- **Zero-Friction Launch**: On app startup, if no user session exists, the app automatically authenticates anonymously in the background via Firebase Auth.
- **Unique User ID**: Every user is immediately assigned a unique Firebase `uid` (e.g. `k9J2mX8aL1p3...`).
- **Data Isolation**: All Firestore writes are saved under `/users/{uid}/...`.

### 2.2 Account Registration & Progress-Preserving Account Linking
- **Account Linking**: When a guest user decides to register with Email & Password in Settings, the app uses Firebase Auth's `linkWithCredential` API.
- **Zero Data Loss**: Account linking converts the anonymous account into a permanent account with the exact same `uid`, preserving all Firestore documents, local SQLite records, bookmarks, history, and SRS card schedules.
- **Standard Sign In**: Existing users can sign into their accounts. If signing into an existing account with pre-existing remote data, local SQLite records are merged with remote Firestore records using Last-Write-Wins (LWW).

### 2.3 Cloud Firestore Synchronization
- **Real Firestore Operations**: Replace the fallback in-memory cache in `FirebaseUserDataDataSource` with real Firestore API calls:
  - Cards Collection: `/users/{uid}/cards/{cardId}`
  - Word Views Collection: `/users/{uid}/views/{word}`
  - Review Logs Collection: `/users/{uid}/review_logs/{logId}`
- **Real-Time Snapshot Listener**: Listen to Firestore changes in real-time so edits made on one device immediately reflect on other signed-in devices.
- **Offline Resiliency**: Firestore offline cache and local SQLite (`user_data.db`) ensure all app features remain 100% operational without network connectivity.

### 2.4 Account Management UI (Settings Screen)
- **Account & Sync Section**: Add a dedicated tile in `SettingsScreen` displaying:
  - Current Auth Status (`Guest User` vs `Signed in as email@example.com`).
  - Shortened User ID badge.
  - "Link Account / Register" button (for Guest users).
  - "Sign In / Switch Account" button.
  - "Sign Out" button.
  - "Sync Now" button with status indicator (e.g. `Last synced 2 mins ago`).

## 3. Non-Functional & Architectural Requirements
- **Decoupled Architecture**: Domain layer and UI screens (except Settings Auth UI) interact only with `AuthRemoteDataSource` and `UserDataRepository` abstraction interfaces.
- **Error Handling**: Network failures or Firebase credential errors must produce user-friendly snackbars without crashing or interrupting offline dictionary searches.
- **Static Analysis & TDD**: Zero dart analyzer warnings and 100% passing test suite.
