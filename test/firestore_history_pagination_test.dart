import 'package:ai_project/services/crypto_service.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/ui/widgets/history/patient_demographics_charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreService.loadCasesPage', () {
    late _HistoryFirestore firestore;
    late FirestoreService service;
    late CryptoService crypto;

    setUp(() {
      firestore = _HistoryFirestore();
      crypto = CryptoService();
      service = FirestoreService(
        firestore: firestore,
        auth: _TestAuth(),
        crypto: crypto,
      );
    });

    test(
      'applies name, outcome, sort, cursor, and page limit server-side',
      () async {
        final cursor = _HistoryDocument(firestore, 'cursor', const {});

        final page = await service.loadCasesPage(
          pageSize: 10,
          newestFirst: false,
          searchText: 'Ada Lov',
          isPneumonia: true,
          startAfter: cursor,
        );

        expect(page.records, isEmpty);
        expect(page.totalCount, 0);
        expect(firestore.query.whereCalls, [
          (
            'patientNamePrefixes',
            'arrayContains',
            await crypto.hashSearchValue('doctor-42', 'ada lov'),
          ),
          ('isPneumonia', 'isEqualTo', true),
        ]);
        expect(firestore.query.orderByField, 'completedAt');
        expect(firestore.query.descending, isFalse);
        expect(firestore.query.cursor, same(cursor));
        expect(firestore.query.limitValue, 10);
      },
    );

    test('supports unfiltered newest-first pages and empty results', () async {
      final page = await service.loadCasesPage(pageSize: 10, newestFirst: true);

      expect(page.records, isEmpty);
      expect(page.totalCount, 0);
      expect(firestore.query.whereCalls, isEmpty);
      expect(firestore.query.descending, isTrue);
    });

    test('uses false for the Normal outcome filter', () async {
      await service.loadCasesPage(
        pageSize: 10,
        newestFirst: true,
        isPneumonia: false,
      );

      expect(firestore.query.whereCalls, [('isPneumonia', 'isEqualTo', false)]);
    });

    test(
      'search returns duplicate matching examinations but excludes others',
      () async {
        await _seedCase(
          service,
          crypto,
          firestore,
          'case-1',
          'Ada Lovelace',
          false,
          DateTime(2026, 1, 1),
        );
        await _seedCase(
          service,
          crypto,
          firestore,
          'case-2',
          'Ada Lovelace',
          true,
          DateTime(2026, 1, 2),
        );
        await _seedCase(
          service,
          crypto,
          firestore,
          'case-3',
          'Grace Hopper',
          false,
          DateTime(2026, 1, 3),
        );

        final page = await service.loadCasesPage(
          pageSize: 10,
          newestFirst: true,
          searchText: ' ADA   LOV ',
        );

        expect(page.records.map((record) => record.id), ['case-2', 'case-1']);
        expect(page.totalCount, 2);
      },
    );

    test('Normal and Pneumonia filters match exact stored booleans', () async {
      await _seedCase(
        service,
        crypto,
        firestore,
        'normal',
        'Patient One',
        false,
        DateTime(2026, 1, 1),
      );
      await _seedCase(
        service,
        crypto,
        firestore,
        'pneumonia',
        'Patient Two',
        true,
        DateTime(2026, 1, 2),
      );
      await _seedCase(
        service,
        crypto,
        firestore,
        'unknown',
        'Patient Three',
        null,
        DateTime(2026, 1, 3),
      );

      final normal = await service.loadCasesPage(
        pageSize: 10,
        newestFirst: true,
        isPneumonia: false,
      );
      final pneumonia = await service.loadCasesPage(
        pageSize: 10,
        newestFirst: true,
        isPneumonia: true,
      );

      expect(normal.records.map((record) => record.id), ['normal']);
      expect(normal.totalCount, 1);
      expect(pneumonia.records.map((record) => record.id), ['pneumonia']);
      expect(pneumonia.totalCount, 1);
    });

    test(
      'saves encrypted cases with searchable names and exact outcomes',
      () async {
        final cases = [
          PredictionHistoryItem(
            id: 'saved-normal',
            patientName: 'Ada Lovelace',
            label: 'Normal',
            probability: 0.91,
            isPneumonia: false,
            completedAt: DateTime(2026, 2, 1),
          ),
          PredictionHistoryItem(
            id: 'saved-pneumonia',
            patientName: 'Grace Hopper',
            label: 'Pneumonia',
            probability: 0.82,
            isPneumonia: true,
            completedAt: DateTime(2026, 2, 2),
          ),
        ];
        for (final item in cases) {
          await service.saveCase(item);
        }

        final rawNormal = firestore.documents.singleWhere(
          (document) => document.id == 'saved-normal',
        );
        final rawPneumonia = firestore.documents.singleWhere(
          (document) => document.id == 'saved-pneumonia',
        );
        expect(rawNormal.values['isPneumonia'], isFalse);
        expect(rawPneumonia.values['isPneumonia'], isTrue);
        expect(rawNormal.values['payload'], startsWith(CryptoService.prefix));
        expect(
          rawPneumonia.values['payload'],
          startsWith(CryptoService.prefix),
        );
        expect(
          (await crypto.decryptJson(
            'doctor-42',
            rawNormal.values['payload'] as String,
          ))['isPneumonia'],
          isFalse,
        );
        expect(
          (await crypto.decryptJson(
            'doctor-42',
            rawPneumonia.values['payload'] as String,
          ))['isPneumonia'],
          isTrue,
        );

        final normal = await service.loadCasesPage(
          pageSize: 10,
          newestFirst: true,
          searchText: 'ada lov',
          isPneumonia: false,
        );
        final pneumonia = await service.loadCasesPage(
          pageSize: 10,
          newestFirst: true,
          searchText: 'grace hop',
          isPneumonia: true,
        );
        expect(normal.records.map((record) => record.id), ['saved-normal']);
        expect(pneumonia.records.map((record) => record.id), [
          'saved-pneumonia',
        ]);
      },
    );

    test('combined query sorts and paginates without duplicates', () async {
      for (var index = 0; index < 12; index++) {
        await _seedCase(
          service,
          crypto,
          firestore,
          'record-$index',
          'Patient Archive',
          true,
          DateTime(2026, 1, index + 1),
        );
      }

      final first = await service.loadCasesPage(
        pageSize: 10,
        newestFirst: false,
        searchText: 'patient arc',
        isPneumonia: true,
      );
      final second = await service.loadCasesPage(
        pageSize: 10,
        newestFirst: false,
        searchText: 'patient arc',
        isPneumonia: true,
        startAfter: first.lastDocument,
      );

      expect(first.records.map((record) => record.id).toList(), [
        for (var index = 0; index < 10; index++) 'record-$index',
      ]);
      expect(second.records.map((record) => record.id), [
        'record-10',
        'record-11',
      ]);
      expect(first.totalCount, 12);
      expect(second.totalCount, 12);
    });

    test(
      'all historical graph datasets receive records across pages',
      () async {
        await _seedCase(
          service,
          crypto,
          firestore,
          'page-1a',
          'Patient A',
          false,
          DateTime(2026, 1, 1),
          age: 18,
          gender: 'female',
        );
        await _seedCase(
          service,
          crypto,
          firestore,
          'page-1b',
          'Patient B',
          true,
          DateTime(2026, 1, 2),
          age: 31,
          gender: 'male',
        );
        await _seedCase(
          service,
          crypto,
          firestore,
          'page-2a',
          'Patient C',
          false,
          DateTime(2026, 1, 3),
          age: 62,
          gender: 'other',
        );
        await _seedCase(
          service,
          crypto,
          firestore,
          'page-2b',
          'Patient D',
          true,
          DateTime(2026, 1, 4),
          age: 8,
          gender: 'female',
        );

        final records = await service.loadAllCases(batchSize: 2);
        final demographics = PatientDemographicsData.fromRecords(records);

        expect(records, hasLength(4));
        expect(demographics.ageCounts, [1, 1, 1, 0, 1]);
        expect(demographics.genderCounts, {
          'Male': 1,
          'Female': 2,
          'Other': 1,
          'Unknown': 0,
        });
        expect(records.where((record) => record.isPneumonia), hasLength(2));
        expect(
          records.map((record) => record.completedAt).toSet(),
          hasLength(4),
        );
      },
    );

    test('loads legacy history records without a completedAt field', () async {
      final payload = await crypto.encryptJson('doctor-42', {
        'patientName': 'Undated Patient',
        'label': 'Normal',
        'probability': 0.7,
        'isPneumonia': false,
      });
      firestore.addRawCase('undated', {'payload': payload});
      await _seedCase(
        service,
        crypto,
        firestore,
        'dated',
        'Dated Patient',
        true,
        DateTime(2024, 1, 1),
      );

      final records = await service.loadAllCases(batchSize: 1);

      expect(records, hasLength(2));
      expect(
        records.map((record) => record.id),
        containsAll(['dated', 'undated']),
      );
    });

    test(
      'legacy record is indexed before searches and keeps outcome meaning',
      () async {
        final payload = await crypto.encryptJson('doctor-42', {
          'patientName': 'Legacy Patient',
          'label': 'Pneumonia',
          'probability': 0.8,
          'isPneumonia': true,
          'completedAt': DateTime(2025, 5, 1).toIso8601String(),
        });
        firestore.addRawCase('legacy', {
          'completedAt': Timestamp.fromDate(DateTime(2025, 5, 1)),
          'payload': payload,
          'encVersion': 1,
        });

        final beforeIndex = await service.getCaseIndexStatus();
        expect(beforeIndex.isComplete, isFalse);

        final results = await service.loadCasesPage(
          pageSize: 10,
          newestFirst: true,
          searchText: 'legacy pat',
          isPneumonia: true,
        );

        expect(results.records.map((record) => record.id), ['legacy']);
        expect(results.totalCount, 1);
        expect((await service.getCaseIndexStatus()).isComplete, isTrue);
      },
    );

    test('propagates Firestore query errors to the caller', () async {
      firestore.queryError = StateError('offline');

      await expectLater(
        service.loadCasesPage(pageSize: 10, newestFirst: true),
        throwsA(isA<StateError>()),
      );
    });
  });
}

Future<void> _seedCase(
  FirestoreService service,
  CryptoService crypto,
  _HistoryFirestore firestore,
  String id,
  String name,
  bool? isPneumonia,
  DateTime completedAt, {
  int? age,
  String? gender,
}) async {
  final payload = <String, dynamic>{
    'patientName': name,
    'label': isPneumonia == null
        ? 'Unrecognized'
        : isPneumonia
        ? 'Pneumonia'
        : 'Normal',
    'probability': 0.8,
    if (age case final value?) 'patientAge': value,
    if (gender case final value?) 'patientGender': value,
    if (isPneumonia case final value?) 'isPneumonia': value,
  };
  firestore.addRawCase(id, {
    'id': id,
    'completedAt': Timestamp.fromDate(completedAt),
    'patientNamePrefixes': await service.patientNameSearchTokens(name),
    'searchIndexVersion': 1,
    if (isPneumonia case final value?) 'isPneumonia': value,
    'payload': await crypto.encryptJson('doctor-42', payload),
    'encVersion': 1,
  });
}

class _HistoryFirestore implements FirebaseFirestore {
  _HistoryFirestore() {
    collectionReference = _newCollection();
  }

  final documents = <_HistoryDocument>[];
  final queries = <_HistoryQuery>[];
  late final _HistoryCollection collectionReference;
  _HistoryQuery get query => queries.last;
  Object? queryError;

  _HistoryCollection _newCollection() {
    final query = _HistoryQuery(this);
    queries.add(query);
    return _HistoryCollection(this, query);
  }

  void addRawCase(String id, Map<String, dynamic> data) {
    documents.add(_HistoryDocument(this, id, data));
  }

  List<_HistoryDocument> matchingDocuments(_HistoryQuery query) {
    return documents.where((document) {
      for (final (field, operator, expected) in query.whereCalls) {
        final actual = document.values[field];
        if (operator == 'arrayContains') {
          if (actual is! List || !actual.contains(expected)) return false;
        } else if (actual != expected) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  WriteBatch batch() => _HistoryBatch(this);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _newCollection();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class, must_be_immutable
class _HistoryQuery implements Query<Map<String, dynamic>> {
  _HistoryQuery(this.owner);

  final _HistoryFirestore owner;
  final whereCalls = <(Object?, String, Object?)>[];
  Object? orderByField;
  bool? descending;
  int? limitValue;
  DocumentSnapshot<Map<String, dynamic>>? cursor;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final member = invocation.memberName;
    if (member == #where) {
      final named = invocation.namedArguments;
      final isArrayContains = named[#arrayContains] != null;
      final filterName = isArrayContains ? 'arrayContains' : 'isEqualTo';
      whereCalls.add((
        invocation.positionalArguments.first,
        filterName,
        named[Symbol(filterName)] ?? named[#isEqualTo],
      ));
      return this;
    }
    if (member == #orderBy) {
      orderByField = invocation.positionalArguments.first;
      descending = invocation.namedArguments[#descending] as bool? ?? false;
      return this;
    }
    if (member == #limit) {
      limitValue = invocation.positionalArguments.first as int;
      return this;
    }
    if (member == #startAfterDocument) {
      cursor =
          invocation.positionalArguments.first
              as DocumentSnapshot<Map<String, dynamic>>;
      return this;
    }
    if (member == #count) return _HistoryAggregate(this);
    if (member == #get) {
      if (owner.queryError != null) {
        return Future<QuerySnapshot<Map<String, dynamic>>>.error(
          owner.queryError!,
        );
      }
      var documents = owner.matchingDocuments(this);
      if (orderByField == 'completedAt') {
        documents.sort((a, b) {
          final aDate = _asDateTime(a.values['completedAt']);
          final bDate = _asDateTime(b.values['completedAt']);
          final comparison = aDate.compareTo(bDate);
          return descending == true ? -comparison : comparison;
        });
      } else if (orderByField is FieldPath) {
        documents.sort((a, b) => a.id.compareTo(b.id));
      }
      if (cursor is _HistoryDocument) {
        final cursorIndex = documents.indexWhere(
          (document) => document.id == cursor!.id,
        );
        if (cursorIndex >= 0) {
          documents = documents.skip(cursorIndex + 1).toList();
        }
      }
      if (limitValue != null) {
        documents = documents.take(limitValue!).toList();
      }
      return Future<QuerySnapshot<Map<String, dynamic>>>.value(
        _HistorySnapshot(documents),
      );
    }
    return super.noSuchMethod(invocation);
  }
}

// ignore: subtype_of_sealed_class
class _HistoryCollection implements CollectionReference<Map<String, dynamic>> {
  _HistoryCollection(this.firestore, this.query);

  @override
  final _HistoryFirestore firestore;
  final _HistoryQuery query;
  @override
  String get path => 'users/doctor-42/cases';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #doc) {
      return _CursorReference(
        firestore,
        invocation.positionalArguments.first as String,
      );
    }
    return query.noSuchMethod(invocation);
  }
}

class _HistoryAggregate implements AggregateQuery {
  _HistoryAggregate(this.query);

  @override
  final Query query;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #get) {
      return Future<AggregateQuerySnapshot>.value(
        _HistoryAggregateSnapshot(
          query,
          (query as _HistoryQuery).owner
              .matchingDocuments(query as _HistoryQuery)
              .length,
        ),
      );
    }
    return super.noSuchMethod(invocation);
  }
}

class _HistoryAggregateSnapshot implements AggregateQuerySnapshot {
  _HistoryAggregateSnapshot(this.query, this.count);

  @override
  final Query query;
  @override
  final int count;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _HistorySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  _HistorySnapshot(this.docs);

  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
// ignore: subtype_of_sealed_class
class _HistoryDocument implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _HistoryDocument(this.owner, this.id, this.values);

  final _HistoryFirestore owner;
  @override
  final String id;
  final Map<String, dynamic> values;
  @override
  bool get exists => true;
  @override
  Map<String, dynamic> data() => Map<String, dynamic>.from(values);
  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      _HistoryDocumentReference(owner, id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DateTime _asDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.fromMillisecondsSinceEpoch(0);
}

// ignore: subtype_of_sealed_class
class _HistoryDocumentReference
    implements DocumentReference<Map<String, dynamic>> {
  _HistoryDocumentReference(this.owner, this.id);

  final _HistoryFirestore owner;
  @override
  final String id;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #set) {
      final data = invocation.positionalArguments[0] as Map<String, dynamic>;
      final index = owner.documents.indexWhere((document) => document.id == id);
      if (index >= 0) owner.documents[index].values.addAll(data);
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

class _HistoryBatch implements WriteBatch {
  _HistoryBatch(this.owner);

  final _HistoryFirestore owner;
  final writes = <(_HistoryDocumentReference, Map<String, dynamic>)>[];

  @override
  Future<void> commit() async {
    for (final (reference, data) in writes) {
      final index = owner.documents.indexWhere(
        (document) => document.id == reference.id,
      );
      if (index >= 0) owner.documents[index].values.addAll(data);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #set) {
      writes.add((
        invocation.positionalArguments[0] as _HistoryDocumentReference,
        invocation.positionalArguments[1] as Map<String, dynamic>,
      ));
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

// ignore: subtype_of_sealed_class
class _CursorReference implements DocumentReference<Map<String, dynamic>> {
  _CursorReference(this.firestore, this.id);

  @override
  final _HistoryFirestore firestore;
  @override
  final String id;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #collection) return firestore._newCollection();
    if (invocation.memberName == #set) {
      firestore.addRawCase(
        id,
        Map<String, dynamic>.from(
          invocation.positionalArguments.first as Map<String, dynamic>,
        ),
      );
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

class _TestAuth implements FirebaseAuth {
  @override
  final User currentUser = _TestUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUser implements User {
  @override
  String get uid => 'doctor-42';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
