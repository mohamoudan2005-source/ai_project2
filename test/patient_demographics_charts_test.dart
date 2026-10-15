import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/ui/widgets/history/patient_demographics_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  group('PatientDemographicsData', () {
    test('groups valid ages and excludes missing or invalid ages', () {
      final data = PatientDemographicsData.fromRecords([
        _record(age: 0),
        _record(age: 17),
        _record(age: 18),
        _record(age: 29),
        _record(age: 30),
        _record(age: 44),
        _record(age: 45),
        _record(age: 59),
        _record(age: 60),
        _record(age: 125),
        _record(age: -1),
        _record(age: 126),
        _record(),
      ]);

      expect(data.ageCounts, [2, 2, 2, 2, 2]);
      expect(data.validAgeRecordCount, 10);
      expect(data.totalRecordCount, 13);
    });

    test('normalizes gender and retains missing or unknown records', () {
      final data = PatientDemographicsData.fromRecords([
        _record(gender: 'male'),
        _record(gender: ' MALE '),
        _record(gender: 'Female'),
        _record(gender: 'FEMALE'),
        _record(gender: 'Other'),
        _record(gender: 'Unlisted value'),
        _record(gender: ''),
        _record(),
      ]);

      expect(data.genderCounts, {
        'Male': 2,
        'Female': 2,
        'Other': 1,
        'Unknown': 3,
      });
      expect(data.totalRecordCount, 8);
    });

    test('parses malformed optional demographic fields without failing', () {
      final record = PredictionHistoryItem.fromJson({
        'patientAge': 42.5,
        'patientGender': 42,
        'label': 'Normal',
        'probability': 0.9,
        'isPneumonia': false,
      });

      expect(record.patientAge, isNull);
      expect(record.patientGender, isNull);
    });

    test('does not classify malformed outcomes as Normal', () {
      final record = PredictionHistoryItem.fromJson({
        'label': 'Normal',
        'probability': 0.9,
        'isPneumonia': 'false',
      });

      expect(record.classificationKnown, isFalse);
      expect(record.isPneumonia, isFalse);
      expect(record.toJson(), isNot(contains('isPneumonia')));
    });

    test('recognizes legacy records from explicit classification labels', () {
      final normal = PredictionHistoryItem.fromJson({
        'label': ' normal ',
        'probability': 0.9,
      });
      final pneumonia = PredictionHistoryItem.fromJson({
        'label': 'PNEUMONIA',
        'probability': 0.8,
      });

      expect(normal.classificationKnown, isTrue);
      expect(normal.isPneumonia, isFalse);
      expect(pneumonia.classificationKnown, isTrue);
      expect(pneumonia.isPneumonia, isTrue);
    });
  });

  testWidgets('shows loading messages for both charts', (tester) async {
    await tester.pumpWidget(_chartTestApp(isLoading: true));

    expect(find.text('Loading examination records...'), findsNWidgets(2));
  });

  testWidgets('shows empty messages when there are no records', (tester) async {
    await tester.pumpWidget(_chartTestApp());

    expect(find.text('No valid patient ages recorded yet.'), findsOneWidget);
    expect(find.text('No examination records yet.'), findsOneWidget);
  });

  testWidgets('shows load errors for both charts', (tester) async {
    await tester.pumpWidget(
      _chartTestApp(error: 'Unable to load examination records.'),
    );

    expect(find.text('Unable to load examination records.'), findsNWidgets(2));
  });

  testWidgets('renders populated charts on mobile and desktop widths', (
    tester,
  ) async {
    final records = [
      _record(age: 12, gender: 'male'),
      _record(age: 27, gender: 'Female'),
      _record(age: 38, gender: 'Other'),
      _record(age: 63),
    ];

    for (final size in [const Size(320, 700), const Size(1280, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(_chartTestApp(records: records));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _chartTestApp({
  List<PredictionHistoryItem> records = const [],
  bool isLoading = false,
  String? error,
}) {
  return ScreenUtilInit(
    designSize: const Size(430, 932),
    minTextAdapt: true,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PatientDemographicsCharts(
            records: records,
            isLoading: isLoading,
            error: error,
          ),
        ),
      ),
    ),
  );
}

PredictionHistoryItem _record({int? age, String? gender}) {
  return PredictionHistoryItem(
    patientAge: age,
    patientGender: gender,
    label: 'Normal',
    probability: 0.9,
    isPneumonia: false,
    completedAt: DateTime(2026),
  );
}
