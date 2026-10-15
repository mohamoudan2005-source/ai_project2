import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/models/user_profile.dart';
import 'package:ai_project/services/crypto_service.dart';

class ExaminationPage {
  const ExaminationPage({
    required this.records,
    required this.totalCount,
    required this.lastDocument,
  });

  final List<PredictionHistoryItem> records;
  final int totalCount;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}

class ExaminationIndexStatus {
  const ExaminationIndexStatus({
    required this.totalCount,
    required this.indexedCount,
  });

  final int totalCount;
  final int indexedCount;

  int get remainingCount => totalCount - indexedCount;
  bool get isComplete => remainingCount == 0;
}

/// Reusable service handling all user-isolated Cloud Firestore operations.
/// Every user document and subcollection path is dynamically scoped to
/// `FirebaseAuth.instance.currentUser!.uid`.
///
/// Sensitive fields (profile PII and the full case payload) are encrypted on
/// the client with AES-256-GCM before being written to Firestore.
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CryptoService _crypto;
  bool _caseSearchIndexesReady = false;

  /// Profile fields stored encrypted. uid, username, email, provider, photo
  /// URLs, streaks and timestamps stay plaintext.
  static const Set<String> _encryptedProfileFields = {
    'fullName',
    'displayName',
    'gender',
    'phone',
    'specialty',
    'hospitalClinic',
    'city',
    'country',
    'licenseNumber',
  };

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    CryptoService? crypto,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _crypto = crypto ?? CryptoService();

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

  // ── ENCRYPTION HELPERS ──────────────────────────────────────────────────────

  /// Returns a copy of a profile map with encrypted fields decrypted.
  /// Plaintext legacy values pass through. Fields that can't be decrypted
  /// (e.g. another user's profile, or a missing key) are dropped rather than
  /// shown as ciphertext.
  Future<Map<String, dynamic>> _decryptProfile(
    Map<String, dynamic> raw,
    String ownerUid,
  ) async {
    final out = Map<String, dynamic>.from(raw);
    for (final field in _encryptedProfileFields) {
      final value = out[field];
      if (value is! String) continue;
      try {
        out[field] = await _crypto.decryptString(ownerUid, value);
      } catch (e) {
        debugPrint('FirestoreService: cannot decrypt "$field": $e');
        out.remove(field);
      }
    }
    if (raw.containsKey('displayName') && out['displayName'] == null) {
      out['displayName'] = 'User';
    }
    return out;
  }

  /// Builds a case document with encrypted clinical data and separate
  /// query metadata. Name prefixes are user-keyed HMACs, not plaintext.
  Future<Map<String, dynamic>> _encodeCase(
    Map<String, dynamic> json,
    String caseId,
    Object completedAt,
  ) async {
    final payload = Map<String, dynamic>.from(json)
      ..remove('id')
      ..remove('completedAt')
      ..remove('classificationKnown');
    final isPneumonia = json['classificationKnown'] == false
        ? null
        : _outcomeFromPayload(json);
    if (isPneumonia == null) payload.remove('isPneumonia');
    return {
      'id': caseId,
      'completedAt': completedAt,
      'patientNamePrefixes': await patientNameSearchTokens(
        json['patientName'] as String?,
      ),
      'searchIndexVersion': 1,
      if (isPneumonia case final outcome?) 'isPneumonia': outcome,
      'payload': await _crypto.encryptJson(currentUserId, payload),
      'encVersion': 1,
    };
  }

  static String normalizePatientNameSearch(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static bool? _outcomeFromPayload(Map<String, dynamic> data) {
    final outcome = data['isPneumonia'];
    if (outcome is bool) return outcome;
    if (data.containsKey('isPneumonia')) return null;
    return switch ((data['label'] as String?)?.trim().toLowerCase()) {
      'normal' => false,
      'pneumonia' => true,
      _ => null,
    };
  }

  Future<List<String>> patientNameSearchTokens(String? patientName) async {
    final normalized = normalizePatientNameSearch(patientName ?? '');
    if (normalized.isEmpty) return const [];

    final prefixes = <String>{};
    final terms = {normalized, ...normalized.split(RegExp(r'\s+'))};
    for (final term in terms) {
      final characters = term.runes.take(64).toList();
      for (var length = 1; length <= characters.length; length++) {
        prefixes.add(String.fromCharCodes(characters.take(length)));
      }
    }

    final hashes = <String>[];
    for (final prefix in prefixes) {
      hashes.add(await _crypto.hashSearchValue(currentUserId, prefix));
    }
    return hashes;
  }

  Future<String> _patientSearchHash(String query) async {
    final normalized = String.fromCharCodes(
      normalizePatientNameSearch(query).runes.take(64),
    );
    return _crypto.hashSearchValue(currentUserId, normalized);
  }

  /// Reverses [_encodeCase]. Documents without a `payload` are legacy
  /// plaintext cases and are returned as-is.
  Future<Map<String, dynamic>> _decodeCase(
    Map<String, dynamic> raw,
    String docId,
  ) async {
    final payload = raw['payload'];
    Map<String, dynamic> data;
    if (payload is String && CryptoService.isEncrypted(payload)) {
      data = await _crypto.decryptJson(currentUserId, payload);
      if (raw['completedAt'] != null) data['completedAt'] = raw['completedAt'];
    } else {
      data = Map<String, dynamic>.from(raw);
    }
    data['id'] = docId;
    return data;
  }

  // ── USER PROFILE ────────────────────────────────────────────────────────────

  /// Saves or updates the user profile in Firestore at `users/{uid}`.
  Future<void> saveUserProfile(
    User user, {
    String? provider,
    String? fullName,
    String? username,
    String? gender,
    String? phone,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final existing = await _decryptProfile(snapshot.data() ?? {}, user.uid);

    String providerId = provider ?? 'firebase';
    if (user.providerData.isNotEmpty) {
      providerId = user.providerData.first.providerId;
    }

    final requestedName = fullName?.trim();
    final existingFullName = existing['fullName'];
    final existingDisplayName = existing['displayName'];
    final emailAlias = user.email?.split('@').first;
    final resolvedFullName = requestedName != null && requestedName.isNotEmpty
        ? requestedName
        : (existingFullName is String &&
                  existingFullName.trim().isNotEmpty &&
                  existingFullName.trim() != emailAlias
              ? existingFullName
              : (user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!.trim()
                    : (existingDisplayName is String &&
                              existingDisplayName.trim().isNotEmpty &&
                              existingDisplayName != emailAlias
                          ? existingDisplayName
                          : null)));
    final effectiveDisplayName = resolvedFullName ?? 'User';

    final encDisplayName = await _crypto.encryptString(
      user.uid,
      effectiveDisplayName,
    );
    final encGender = gender == null
        ? null
        : await _crypto.encryptString(user.uid, gender);
    final encPhone = phone == null
        ? null
        : await _crypto.encryptString(user.uid, phone);

    final data = <String, dynamic>{
      'uid': user.uid,
      'username':
          username ??
          (user.email != null && user.email!.isNotEmpty
              ? user.email!.split('@').first
              : ''),
      'displayName': encDisplayName,
      'gender': ?encGender,
      'phone': ?encPhone,
      'email': user.email ?? '',
      'provider': providerId,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
    if (resolvedFullName != null) {
      data['fullName'] = await _crypto.encryptString(
        user.uid,
        resolvedFullName,
      );
    }

    if (!snapshot.exists) {
      data['photoURL'] = user.photoURL ?? '';
      data['createdAt'] = FieldValue.serverTimestamp();
      data['streaks'] = 0;
      await docRef.set(data);
    } else {
      final existingPhotoUrl = snapshot.data()?['photoURL'];
      if (existingPhotoUrl is! String || existingPhotoUrl.isEmpty) {
        data['photoURL'] = user.photoURL ?? '';
      }
      if (snapshot.data()?['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  /// Updates the authenticated doctor's profile at `users/{current uid}`.
  Future<void> updateDoctorProfile({
    required String fullName,
    String? gender,
    String? phone,
    String? specialty,
    String? hospitalClinic,
    String? city,
    String? country,
    String? licenseNumber,
  }) async {
    final uid = currentUserId;
    final trimmedName = fullName.trim();
    final encName = await _crypto.encryptString(uid, trimmedName);

    final data = <String, dynamic>{
      'fullName': encName,
      'displayName': encName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    Future<void> setOptionalField(String key, String? value) async {
      final normalizedValue = value?.trim() ?? '';
      data[key] = normalizedValue.isEmpty
          ? FieldValue.delete()
          : await _crypto.encryptString(uid, normalizedValue);
    }

    await setOptionalField('gender', gender);
    await setOptionalField('phone', phone);
    await setOptionalField('specialty', specialty);
    await setOptionalField('hospitalClinic', hospitalClinic);
    await setOptionalField('city', city);
    await setOptionalField('country', country);
    await setOptionalField('licenseNumber', licenseNumber);

    await _userDocRef.set(data, SetOptions(merge: true));
  }

  /// Updates only the authenticated user's application profile image URL.
  Future<void> updateProfilePhotoUrl(String photoURL) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    // Store the app's custom profile image separately from provider photos.
    await _firestore.collection('users').doc(user.uid).set({
      'profileImage': photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Real-time stream of the authenticated user's profile document from Firestore.
  Stream<UserProfile?> userProfileStream([String? uid]) {
    final user = _auth.currentUser;
    if (user == null && uid == null) {
      return Stream.value(null);
    }
    final targetUid = uid ?? user!.uid;
    return _firestore.collection('users').doc(targetUid).snapshots().asyncMap((
      snap,
    ) async {
      if (!snap.exists || snap.data() == null) return null;
      final decrypted = await _decryptProfile(snap.data()!, targetUid);
      return UserProfile.fromMap(decrypted);
    });
  }

  /// Retrieves the user profile document from Firestore.
  Future<UserProfile?> getUserProfile([String? uid]) async {
    final targetUid = uid ?? currentUserId;
    final doc = await _firestore.collection('users').doc(targetUid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    final decrypted = await _decryptProfile(doc.data()!, targetUid);
    return UserProfile.fromMap(decrypted);
  }

  // ── CASES (USER DATA ISOLATION) ─────────────────────────────────────────────

  /// Loads all examination cases for the current authenticated user from
  /// `users/{uid}/cases` sorted newest first.
  Future<List<PredictionHistoryItem>> loadCases() async {
    return loadAllCases();
  }

  /// Loads every record in bounded Firestore requests for complete historical
  /// statistics. Payloads are decrypted before they are returned to callers.
  /// Any unreadable record fails the operation so charts never present partial
  /// historical results as complete.
  Future<List<PredictionHistoryItem>> loadAllCases({
    int batchSize = 100,
  }) async {
    final cases = <PredictionHistoryItem>[];
    DocumentSnapshot<Map<String, dynamic>>? cursor;

    while (true) {
      Query<Map<String, dynamic>> query = _casesRef
          .orderBy(FieldPath.documentId)
          .limit(batchSize);
      if (cursor != null) query = query.startAfterDocument(cursor);
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final data = await _decodeCase(doc.data(), doc.id);
        cases.add(PredictionHistoryItem.fromJson(data));
      }
      if (snapshot.docs.length < batchSize) break;
      cursor = snapshot.docs.last;
    }
    cases.sort((a, b) {
      final dateOrder = b.completedAt.compareTo(a.completedAt);
      if (dateOrder != 0) return dateOrder;
      return (a.id ?? '').compareTo(b.id ?? '');
    });
    return cases;
  }

  /// Fetches one server-paginated page. Search matches the beginning of any
  /// patient-name word; arbitrary substring matching is not supported by
  /// Firestore's native query operators.
  Future<ExaminationPage> loadCasesPage({
    required int pageSize,
    required bool newestFirst,
    String searchText = '',
    bool? isPneumonia,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    await ensureCaseSearchIndexes();
    Query<Map<String, dynamic>> baseQuery = _casesRef;
    final normalizedSearch = normalizePatientNameSearch(searchText);
    if (normalizedSearch.isNotEmpty) {
      baseQuery = baseQuery.where(
        'patientNamePrefixes',
        arrayContains: await _patientSearchHash(normalizedSearch),
      );
    }
    if (isPneumonia != null) {
      baseQuery = baseQuery.where('isPneumonia', isEqualTo: isPneumonia);
    }
    Query<Map<String, dynamic>> query = baseQuery.orderBy(
      'completedAt',
      descending: newestFirst,
    );
    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshots = await Future.wait([
      query.limit(pageSize).get(),
      baseQuery.count().get(),
    ]);
    final pageSnapshot = snapshots[0] as QuerySnapshot<Map<String, dynamic>>;
    final countSnapshot = snapshots[1] as AggregateQuerySnapshot;
    final records = <PredictionHistoryItem>[];
    for (final document in pageSnapshot.docs) {
      final data = await _decodeCase(document.data(), document.id);
      records.add(PredictionHistoryItem.fromJson(data));
    }

    return ExaminationPage(
      records: records,
      totalCount: countSnapshot.count ?? 0,
      lastDocument: pageSnapshot.docs.isEmpty ? null : pageSnapshot.docs.last,
    );
  }

  /// Backfills only the query metadata for legacy encrypted records, in
  /// bounded batches. Called explicitly by the authenticated doctor.
  Future<int> backfillCaseSearchIndexes() async {
    const batchSize = 100;
    Query<Map<String, dynamic>> query = _casesRef
        .orderBy(FieldPath.documentId)
        .limit(batchSize);
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    var updatedCount = 0;

    while (true) {
      final page =
          await (cursor == null ? query : query.startAfterDocument(cursor))
              .get();
      if (page.docs.isEmpty) break;

      final batch = _firestore.batch();
      var batchHasWrites = false;
      for (final document in page.docs) {
        final raw = document.data();
        if (raw['searchIndexVersion'] == 1) {
          continue;
        }
        final data = await _decodeCase(raw, document.id);
        final metadata = <String, dynamic>{
          'patientNamePrefixes': await patientNameSearchTokens(
            data['patientName'] is String
                ? data['patientName'] as String
                : null,
          ),
          'searchIndexVersion': 1,
        };
        final outcome = _outcomeFromPayload(data);
        if (outcome != null) metadata['isPneumonia'] = outcome;
        batch.set(document.reference, metadata, SetOptions(merge: true));
        updatedCount++;
        batchHasWrites = true;
      }
      if (batchHasWrites) await batch.commit();

      cursor = page.docs.last;
      if (page.docs.length < batchSize) break;
    }
    return updatedCount;
  }

  Future<ExaminationIndexStatus> getCaseIndexStatus() async {
    final counts = await Future.wait([
      _casesRef.count().get(),
      _casesRef.where('searchIndexVersion', isEqualTo: 1).count().get(),
    ]);
    return ExaminationIndexStatus(
      totalCount: counts[0].count ?? 0,
      indexedCount: counts[1].count ?? 0,
    );
  }

  Future<ExaminationIndexStatus> ensureCaseSearchIndexes() async {
    if (_caseSearchIndexesReady) return getCaseIndexStatus();

    var status = await getCaseIndexStatus();
    if (!status.isComplete) {
      await backfillCaseSearchIndexes();
      status = await getCaseIndexStatus();
    }
    if (!status.isComplete) {
      throw StateError(
        '${status.remainingCount} examination records still need search indexing.',
      );
    }
    _caseSearchIndexesReady = true;
    return status;
  }

  /// Saves a new examination case under `users/{uid}/cases/{caseId}`.
  Future<String> saveCase(
    PredictionHistoryItem caseItem, {
    String? explicitCaseId,
  }) async {
    final String caseId = explicitCaseId ?? caseItem.id ?? const Uuid().v4();
    final data = await _encodeCase(
      Map<String, dynamic>.from(caseItem.toJson()),
      caseId,
      Timestamp.fromDate(caseItem.completedAt),
    );
    await _casesRef.doc(caseId).set(data);
    return caseId;
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
  /// WITHOUT deleting or corrupting any existing data. Migrated cases are
  /// encrypted on the way in.
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
          final legacy = doc.data();
          final encoded = await _encodeCase(
            legacy,
            doc.id,
            legacy['completedAt'] ?? Timestamp.now(),
          );
          await _casesRef.doc(doc.id).set(encoded);
          migratedCases++;
        }
      }
    } catch (e) {
      debugPrint('FirestoreService: Legacy migration notice: $e');
    }
    return migratedCases;
  }
}
