import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/models/user_profile.dart';

/// Reusable service handling all user-isolated Cloud Firestore operations.
/// Every user document and subcollection path is dynamically scoped to
/// `FirebaseAuth.instance.currentUser!.uid`.
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Retrieves the current authenticated user's UID.
  /// Throws [StateError] if no user is signed in to prevent any unauthorized
  /// or unpartitioned data access.
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError(
        'Authentication Error: No authenticated user found. '
        'All Firestore operations require an authenticated user UID.',
      );
    }
    return user.uid;
  }

  /// Reference to `users/{uid}` document
  DocumentReference<Map<String, dynamic>> get _userDocRef {
    return _firestore.collection('users').doc(currentUserId);
  }

  /// Reference to `users/{uid}/cases` subcollection
  CollectionReference<Map<String, dynamic>> get _casesRef {
    return _userDocRef.collection('cases');
  }

  // ── USER PROFILE ────────────────────────────────────────────────────────────

  /// Saves or updates the user profile in Firestore at `users/{uid}`.
  Future<void> saveUserProfile(
    User user, {
    String? provider,
    String? fullName,
    String? username,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    String providerId = provider ?? 'firebase';
    if (user.providerData.isNotEmpty) {
      providerId = user.providerData.first.providerId;
    }

    final effectiveDisplayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (user.displayName ??
              (user.email != null && user.email!.isNotEmpty
                  ? user.email!.split('@').first
                  : 'User'));

    final data = <String, dynamic>{
      'uid': user.uid,
      'fullName': fullName ?? (user.displayName ?? effectiveDisplayName),
      'username':
          username ??
          (user.email != null && user.email!.isNotEmpty
              ? user.email!.split('@').first
              : ''),
      'displayName': effectiveDisplayName,
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'provider': providerId,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['streaks'] = 0;
      await docRef.set(data);
    } else {
      if (snapshot.data()?['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  /// Retrieves the user profile document from Firestore.
  Future<UserProfile?> getUserProfile([String? uid]) async {
    final targetUid = uid ?? currentUserId;
    final doc = await _firestore.collection('users').doc(targetUid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserProfile.fromMap(doc.data()!);
  }

  // ── CASES (USER DATA ISOLATION) ─────────────────────────────────────────────

  /// Loads all examination cases for the current authenticated user from
  /// `users/{uid}/cases` sorted newest first.
  Future<List<PredictionHistoryItem>> loadCases() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _casesRef.get();

    final List<PredictionHistoryItem> cases = snapshot.docs.map((doc) {
      return PredictionHistoryItem.fromJson(doc.data());
    }).toList();

    // Sort descending by completion timestamp
    cases.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return cases;
  }

  /// Saves a new examination case under `users/{uid}/cases/{caseId}`.
  Future<void> saveCase(PredictionHistoryItem caseItem) async {
    final String caseId = const Uuid().v4();
    await _casesRef.doc(caseId).set(caseItem.toJson());
  }

  /// Backward-compatibility aliases matching original DBService method signatures
  Future<List<PredictionHistoryItem>> loadHistory() => loadCases();
  Future<void> saveHistory(PredictionHistoryItem history) => saveCase(history);

  // ── STREAKS ─────────────────────────────────────────────────────────────────

  /// Loads current user's streak count from `users/{uid}`.
  Future<int> loadStreak() async {
    final doc = await _userDocRef.get();
    return (doc.data()?['streaks'] as num?)?.toInt() ?? 0;
  }

  /// Saves current user's streak count to `users/{uid}`.
  Future<void> saveStreak(int streak) async {
    await _userDocRef.set({'streaks': streak}, SetOptions(merge: true));
  }

  // ── SAFE MIGRATION STRATEGY ─────────────────────────────────────────────────

  /// Safely migrates legacy data stored under global/hardcoded doc `users/1`
  /// into the newly authenticated user's scoped path `users/{uid}/cases`
  /// WITHOUT deleting or corrupting any existing data.
  Future<int> migrateLegacyDataIfRequested() async {
    final uid = currentUserId;
    if (uid == '1') return 0; // Already using legacy ID

    int migratedCases = 0;
    try {
      // 1. Check legacy streak
      final legacyUserDoc = await _firestore.collection('users').doc('1').get();
      if (legacyUserDoc.exists) {
        final legacyStreak =
            (legacyUserDoc.data()?['streaks'] as num?)?.toInt() ?? 0;
        if (legacyStreak > 0) {
          final currentUserDoc = await _userDocRef.get();
          final currentStreak =
              (currentUserDoc.data()?['streaks'] as num?)?.toInt() ?? 0;
          if (currentStreak == 0) {
            await saveStreak(legacyStreak);
          }
        }
      }

      // 2. Check legacy history subcollection
      final legacyHistory = await _firestore
          .collection('users')
          .doc('1')
          .collection('history')
          .get();

      for (final doc in legacyHistory.docs) {
        final targetDoc = await _casesRef.doc(doc.id).get();
        if (!targetDoc.exists) {
          await _casesRef.doc(doc.id).set(doc.data());
          migratedCases++;
        }
      }
    } catch (e) {
      debugPrint('FirestoreService: Legacy migration notice: $e');
    }
    return migratedCases;
  }
}
