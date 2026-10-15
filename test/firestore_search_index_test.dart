import 'package:ai_project/services/crypto_service.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('patient name search index', () {
    test(
      'indexes complete-name and word prefixes without storing names',
      () async {
        final crypto = CryptoService();
        final service = FirestoreService(
          firestore: _UnusedFirestore(),
          auth: _TestAuth('doctor-1'),
          crypto: crypto,
        );

        final tokens = await service.patientNameSearchTokens('Ada Lovelace');

        expect(
          tokens,
          contains(await crypto.hashSearchValue('doctor-1', 'ada')),
        );
        expect(
          tokens,
          contains(await crypto.hashSearchValue('doctor-1', 'ada l')),
        );
        expect(
          tokens,
          contains(await crypto.hashSearchValue('doctor-1', 'lov')),
        );
        expect(tokens, isNot(contains('Ada Lovelace')));
        expect(
          await crypto.hashSearchValue('doctor-1', 'ada'),
          isNot(await crypto.hashSearchValue('doctor-2', 'ada')),
        );
      },
    );

    test('normalizes case and surrounding whitespace', () async {
      final service = FirestoreService(
        firestore: _UnusedFirestore(),
        auth: _TestAuth('doctor-1'),
        crypto: CryptoService(),
      );

      expect(
        await service.patientNameSearchTokens('  ADA  LOVELACE '),
        await service.patientNameSearchTokens('ada lovelace'),
      );
    });
  });
}

class _TestAuth implements FirebaseAuth {
  _TestAuth(String uid) : currentUser = _TestUser(uid);

  @override
  final User currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUser implements User {
  _TestUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
