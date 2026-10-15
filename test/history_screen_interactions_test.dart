import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/services/db_service.dart';
import 'package:ai_project/app/ui/screens/history_screen.dart';
import 'package:ai_project/app/ui/widgets/history/mission_card.dart';
import 'package:ai_project/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets(
    'search, clear, filters, combinations, and page reset update visible records',
    (tester) async {
      final service = _HistoryService(_records());
      await tester.pumpWidget(_app(service));
      await _settleHistory(tester);

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);

      await _search(tester, '  lOvElAcE   aDa ');
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsNothing);

      final clearSearch = find.byTooltip('Clear search');
      await tester.ensureVisible(clearSearch);
      await tester.tap(clearSearch);
      await _pumpFrames(tester);
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);

      await _tapChip(tester, 'Normal');
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsNothing);
      expect(find.text('Unknown Patient'), findsNothing);

      await _search(tester, 'grace');
      expect(find.text('No matching examinations'), findsOneWidget);
      await tester.ensureVisible(clearSearch);
      await tester.tap(clearSearch);
      await _pumpFrames(tester);
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsNothing);

      await _tapChip(tester, 'Pneumonia');
      expect(find.text('Grace Hopper'), findsOneWidget);
      expect(find.text('Ada Lovelace'), findsNothing);
      expect(find.text('Unknown Patient'), findsNothing);

      await _tapChip(tester, 'All');
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);
      expect(find.text('Unknown Patient'), findsOneWidget);
    },
  );

  testWidgets('rapid search changes immediately show only the latest query', (
    tester,
  ) async {
    final service = _HistoryService(_records());
    await tester.pumpWidget(_app(service));
    await _settleHistory(tester);

    final field = find.byType(TextField);
    await tester.ensureVisible(field);
    await tester.enterText(field, 'ada');
    await tester.pump();
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsNothing);
    await tester.enterText(field, 'grace');
    await tester.pump();
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsNothing);
  });

  testWidgets('classification filtering remains correct across pages', (
    tester,
  ) async {
    final records = [
      ..._records(),
      for (var index = 0; index < 11; index++)
        PredictionHistoryItem(
          id: 'normal-$index',
          patientName: 'Normal Patient $index',
          label: 'Normal',
          probability: 0.9,
          isPneumonia: false,
          completedAt: DateTime(2026, 2, index + 1),
        ),
    ];
    await tester.pumpWidget(_app(_HistoryService(records)));
    await _settleHistory(tester);

    await _tapChip(tester, 'Normal');
    expect(find.text('Grace Hopper'), findsNothing);
    expect(find.text('Unknown Patient'), findsNothing);
    expect(find.text('Page 1 of 2'), findsOneWidget);

    final next = find.widgetWithText(OutlinedButton, 'Next');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await _pumpFrames(tester);
    expect(find.text('Page 2 of 2'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsNothing);
    expect(find.text('Unknown Patient'), findsNothing);

    await _tapChip(tester, 'Pneumonia');
    expect(find.text('Page 1 of 1'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('Normal Patient 10'), findsNothing);

    await _tapChip(tester, 'Normal');
    expect(find.text('Page 1 of 2'), findsOneWidget);

    await _search(tester, 'Normal Patient 10');
    expect(
      find.descendant(
        of: find.byType(MissionCard),
        matching: find.text('Normal Patient 10'),
      ),
      findsOneWidget,
    );
    expect(find.text('Page 1 of 1'), findsOneWidget);
  });
}

Widget _app(_HistoryService service) {
  final testAuth = _TestAuth();
  final firestore = _UnusedFirestore();
  final firestoreService = FirestoreService(
    firestore: firestore,
    auth: testAuth,
  );
  return ScreenUtilInit(
    designSize: const Size(430, 932),
    child: ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(service),
        authServiceProvider.overrideWithValue(
          AuthService(auth: testAuth, firestoreService: firestoreService),
        ),
        userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const MaterialApp(home: HistoryScreen()),
    ),
  );
}

Future<void> _settleHistory(WidgetTester tester) async {
  await _pumpFrames(tester);
  await tester.pump(const Duration(milliseconds: 400));
  await _pumpFrames(tester);
}

Future<void> _search(WidgetTester tester, String query) async {
  final field = find.byType(TextField);
  await tester.ensureVisible(field);
  await tester.enterText(field, query);
  await tester.pump(const Duration(milliseconds: 351));
  await _pumpFrames(tester);
}

Future<void> _tapChip(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(ChoiceChip, label);
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await _pumpFrames(tester);
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 3; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

List<PredictionHistoryItem> _records() => [
  PredictionHistoryItem(
    id: 'ada',
    patientName: 'Ada Lovelace',
    label: 'Normal',
    probability: 0.9,
    isPneumonia: false,
    completedAt: DateTime(2026, 1, 1),
  ),
  PredictionHistoryItem(
    id: 'grace',
    patientName: 'Grace Hopper',
    label: 'Pneumonia',
    probability: 0.8,
    isPneumonia: true,
    completedAt: DateTime(2026, 1, 2),
  ),
  PredictionHistoryItem(
    id: 'unknown',
    patientName: 'Unknown Patient',
    label: 'Unrecognized',
    probability: 0.5,
    isPneumonia: false,
    classificationKnown: false,
    completedAt: DateTime(2026, 1, 3),
  ),
];

class _HistoryService extends DBService {
  _HistoryService(this.records)
    : super(firestore: _UnusedFirestore(), auth: _TestAuth());

  final List<PredictionHistoryItem> records;

  @override
  Future<List<PredictionHistoryItem>> loadAllCases({
    int batchSize = 100,
  }) async => records;

  @override
  Future<int> loadStreak() async => 0;
}

class _TestAuth implements FirebaseAuth {
  _TestAuth() : currentUser = _TestUser();

  @override
  final User currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUser implements User {
  @override
  String get uid => 'history-widget-test-user';

  @override
  String? get photoURL => null;

  @override
  String? get displayName => null;

  @override
  String? get email => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
