import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:jisho_anki/core/data/datasources/remote_user_data_data_source.dart';
import 'package:jisho_anki/core/domain/entities/user_data/review_log.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_settings_entity.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_view_record.dart';

/// Firebase Firestore & Auth implementation of [RemoteUserDataDataSource].
///
/// Follows Cloud Firestore collection schema:
/// - `users/{userId}/cards/{cardId}`
/// - `users/{userId}/views/{word}`
/// - `users/{userId}/review_logs/{logId}`
///
/// Uses Firestore batch writes and provides resilient offline/fallback support.
class FirebaseUserDataDataSource implements RemoteUserDataDataSource {
  final fs.FirebaseFirestore? _firestoreInstance;
  final fb.FirebaseAuth? _authInstance;

  String? _fallbackUserId;
  final StreamController<String?> _userStreamController =
      StreamController<String?>.broadcast();

  // In-memory fallback backing store when Firebase native SDK is not initialized
  final Map<String, WordCard> _cacheCards = {};
  final Map<String, WordViewRecord> _cacheViews = {};
  final List<ReviewLog> _cacheLogs = [];
  UserSettingsEntity? _cacheSettings;

  FirebaseUserDataDataSource({
    String? initialUserId,
    fs.FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _firestoreInstance = firestore,
        _authInstance = auth {
    _fallbackUserId = initialUserId ?? 'firebase_user_default';
  }

  fs.FirebaseFirestore get _firestore {
    return _firestoreInstance ?? fs.FirebaseFirestore.instance;
  }

  fb.FirebaseAuth get _auth {
    return _authInstance ?? fb.FirebaseAuth.instance;
  }

  bool get _isFirebaseAvailable {
    try {
      _auth.currentUser;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  String? get currentUserId {
    if (_isFirebaseAvailable) {
      try {
        return _auth.currentUser?.uid ?? _fallbackUserId;
      } catch (_) {
        return _fallbackUserId;
      }
    }
    return _fallbackUserId;
  }

  @override
  Stream<String?> watchUserId() {
    if (_isFirebaseAvailable) {
      try {
        return _auth.authStateChanges().map((u) => u?.uid ?? _fallbackUserId);
      } catch (_) {
        // fallback
      }
    }
    return _userStreamController.stream;
  }

  @override
  Future<void> signInAnonymously() async {
    if (_isFirebaseAvailable) {
      try {
        await _auth.signInAnonymously();
        return;
      } catch (e) {
        log('FirebaseUserDataDataSource: Anonymous sign-in failed, using fallback: $e');
      }
    }
    _fallbackUserId = 'firebase_anon_${DateTime.now().millisecondsSinceEpoch}';
    _userStreamController.add(_fallbackUserId);
  }

  String? get _uid => currentUserId;

  @override
  Future<void> pushCards(List<WordCard> cards) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        final batch = _firestore.batch();
        final cardsRef =
            _firestore.collection('users').doc(_uid).collection('cards');
        for (final card in cards) {
          final docRef = cardsRef.doc(card.id);
          batch.set(
              docRef,
              {
                ...card.toMap(),
                'updated_at': card.updatedAt,
              },
              fs.SetOptions(merge: true));
        }
        await batch.commit();
        return;
      } catch (e) {
        log('FirebaseUserDataDataSource: pushCards Firestore error, using fallback cache: $e');
      }
    }
    for (final card in cards) {
      _cacheCards[card.id] = card.copyWith(isSynced: true);
    }
  }

  @override
  Future<List<WordCard>> pullCardsUpdatedSince(int timestamp) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cards')
            .where('updated_at', isGreaterThanOrEqualTo: timestamp)
            .get();
        return querySnapshot.docs
            .map((doc) => WordCard.fromMap(doc.data()))
            .toList();
      } catch (e) {
        log('FirebaseUserDataDataSource: pullCards Firestore error, using fallback cache: $e');
      }
    }
    return _cacheCards.values
        .where((c) => c.updatedAt >= timestamp)
        .toList();
  }

  @override
  Future<void> pushViews(List<WordViewRecord> views) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        final batch = _firestore.batch();
        final viewsRef =
            _firestore.collection('users').doc(_uid).collection('views');
        for (final view in views) {
          final docRef = viewsRef.doc(view.word);
          batch.set(docRef, view.toMap(), fs.SetOptions(merge: true));
        }
        await batch.commit();
        return;
      } catch (e) {
        log('FirebaseUserDataDataSource: pushViews Firestore error, using fallback cache: $e');
      }
    }
    for (final view in views) {
      final existing = _cacheViews[view.word];
      if (existing == null || view.viewCount > existing.viewCount) {
        _cacheViews[view.word] = view.copyWith(isSynced: true);
      }
    }
  }

  @override
  Future<List<WordViewRecord>> pullViews() async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('views')
            .get();
        return querySnapshot.docs
            .map((doc) => WordViewRecord.fromMap(doc.data()))
            .toList();
      } catch (e) {
        log('FirebaseUserDataDataSource: pullViews Firestore error, using fallback cache: $e');
      }
    }
    return _cacheViews.values.toList();
  }

  @override
  Future<void> pushReviewLogs(List<ReviewLog> logs) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        final batch = _firestore.batch();
        final logsRef =
            _firestore.collection('users').doc(_uid).collection('review_logs');
        for (final log in logs) {
          final docRef = logsRef.doc(log.id);
          batch.set(docRef, log.toMap(), fs.SetOptions(merge: true));
        }
        await batch.commit();
        return;
      } catch (e) {
        log('FirebaseUserDataDataSource: pushReviewLogs Firestore error, using fallback cache: $e');
      }
    }
    for (final log in logs) {
      _cacheLogs.removeWhere((l) => l.id == log.id);
      _cacheLogs.add(log);
    }
  }

  @override
  Future<List<ReviewLog>> pullReviewLogs({int? sinceTimestamp}) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        fs.Query<Map<String, dynamic>> query = _firestore
            .collection('users')
            .doc(_uid)
            .collection('review_logs');
        if (sinceTimestamp != null) {
          query = query.where('reviewed_at',
              isGreaterThanOrEqualTo: sinceTimestamp);
        }
        final querySnapshot = await query.get();
        return querySnapshot.docs
            .map((doc) => ReviewLog.fromMap(doc.data()))
            .toList();
      } catch (e) {
        log('FirebaseUserDataDataSource: pullReviewLogs Firestore error, using fallback cache: $e');
      }
    }
    if (sinceTimestamp != null) {
      return _cacheLogs.where((l) => l.reviewedAt >= sinceTimestamp).toList();
    }
    return List.from(_cacheLogs);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cards')
            .doc(cardId)
            .delete();
        return;
      } catch (e) {
        log('FirebaseUserDataDataSource: deleteCard Firestore error, using fallback cache: $e');
      }
    }
    _cacheCards.remove(cardId);
  }

  @override
  Future<void> pushSettings(UserSettingsEntity settings) async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('settings')
            .doc('config')
            .set(settings.toMap(), fs.SetOptions(merge: true));
        return;
      } catch (e) {
        log('FirebaseUserDataDataSource: pushSettings Firestore error, using fallback cache: $e');
      }
    }
    _cacheSettings = settings;
  }

  @override
  Future<UserSettingsEntity?> pullSettings() async {
    if (_isFirebaseAvailable && _uid != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('settings')
            .doc('config')
            .get();
        if (doc.exists && doc.data() != null) {
          return UserSettingsEntity.fromMap(doc.data()!);
        }
      } catch (e) {
        log('FirebaseUserDataDataSource: pullSettings Firestore error, using fallback cache: $e');
      }
    }
    return _cacheSettings;
  }

  void dispose() {
    _userStreamController.close();
  }
}
