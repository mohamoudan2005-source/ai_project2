import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_project/services/crypto_service.dart';
import 'package:ai_project/services/firestore_service.dart';

void main() {
  group('FirestoreService.updateDoctorProfile', () {
    test('writes all fields to the authenticated user document', () async {
      final firestore = _CapturingFirestore();
      final crypto = CryptoService();
      final service = _service(firestore, crypto);

      await service.updateDoctorProfile(
        fullName: ' Dr. Ada Lovelace ',
        gender: 'Female',
        phone: '+1 555 0100',
        specialty: 'Pulmonology',
        hospitalClinic: 'North Clinic',
        city: 'Boston',
        country: 'United States',
        licenseNumber: 'MED-1234',
      );

      expect(firestore.collectionPath, 'users');
      expect(firestore.documentPath, 'doctor-42');
      for (final entry in {
        'fullName': 'Dr. Ada Lovelace',
        'displayName': 'Dr. Ada Lovelace',
        'gender': 'Female',
        'phone': '+1 555 0100',
        'specialty': 'Pulmonology',
        'hospitalClinic': 'North Clinic',
        'city': 'Boston',
        'country': 'United States',
        'licenseNumber': 'MED-1234',
      }.entries) {
        expect(
          await crypto.decryptString(
            'doctor-42',
            firestore.documentData![entry.key] as String,
          ),
          entry.value,
        );
      }
      expect(firestore.documentData!['updatedAt'], isA<FieldValue>());
      expect(firestore.setOptions?.merge, isTrue);
      expect(firestore.documentData!.containsKey('email'), isFalse);
    });

    test(
      'saves one populated optional field without null Firestore values',
      () async {
        final firestore = _CapturingFirestore();
        final crypto = CryptoService();
        final service = _service(firestore, crypto);

        await service.updateDoctorProfile(
          fullName: 'Dr. Ada Lovelace',
          specialty: 'Cardiology',
        );

        expect(
          await crypto.decryptString(
            'doctor-42',
            firestore.documentData!['specialty'] as String,
          ),
          'Cardiology',
        );
        for (final key in [
          'gender',
          'phone',
          'hospitalClinic',
          'city',
          'country',
          'licenseNumber',
        ]) {
          expect(firestore.documentData![key], isA<FieldValue>());
        }
        expect(firestore.documentData!.values, isNot(contains(null)));
      },
    );

    test('clears optional fields using Firestore delete sentinels', () async {
      final firestore = _CapturingFirestore();
      final service = _service(firestore);

      await service.updateDoctorProfile(
        fullName: 'Dr. Ada Lovelace',
        gender: ' ',
        phone: '',
        specialty: '   ',
        hospitalClinic: '',
        city: '',
        country: ' ',
        licenseNumber: '',
      );

      for (final key in [
        'gender',
        'phone',
        'specialty',
        'hospitalClinic',
        'city',
        'country',
        'licenseNumber',
      ]) {
        expect(firestore.documentData![key], isA<FieldValue>());
      }
      expect(firestore.documentData!.values, isNot(contains(null)));
    });

    test('propagates Firestore write failures to the save handler', () async {
      final firestore = _CapturingFirestore()
        ..writeError = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Network unavailable',
        );
      final service = _service(firestore);

      await expectLater(
        service.updateDoctorProfile(fullName: 'Dr. Ada Lovelace'),
        throwsA(same(firestore.writeError)),
      );
    });
  });
}

FirestoreService _service(
  _CapturingFirestore firestore, [
  CryptoService? crypto,
]) {
  return FirestoreService(
    firestore: firestore,
    auth: _CapturingAuth(_CapturingUser('doctor-42')),
    crypto: crypto,
  );
}

class _CapturingAuth implements FirebaseAuth {
  _CapturingAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CapturingUser implements User {
  _CapturingUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _CapturingFirestore implements FirebaseFirestore {
  final _CapturedWrite _write = _CapturedWrite();
  late final _CapturingDocument _document = _CapturingDocument(_write);

  String? collectionPath;
  String? documentPath;

  Map<String, dynamic>? get documentData => _write.data;
  SetOptions? get setOptions => _write.options;
  Object? get writeError => _write.error;
  set writeError(Object? error) => _write.error = error;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    this.collectionPath = collectionPath;
    return _CapturingCollection(this);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _CapturingCollection
    implements CollectionReference<Map<String, dynamic>> {
  _CapturingCollection(this._owner);

  final _CapturingFirestore _owner;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? documentPath]) {
    _owner.documentPath = documentPath;
    return _owner._document;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _CapturingDocument implements DocumentReference<Map<String, dynamic>> {
  _CapturingDocument(this._write);

  final _CapturedWrite _write;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    _write.data = Map<String, dynamic>.from(data);
    _write.options = options;
    if (_write.error != null) throw _write.error!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CapturedWrite {
  Map<String, dynamic>? data;
  SetOptions? options;
  Object? error;
}
