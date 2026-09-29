import 'package:ai_project/app/models/prediction_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_state.freezed.dart';

enum AppScreen { camera, scanning, complete, history }

enum TimeChoice {
  quick,
  solid,
  deep;

  String get label {
    switch (this) {
      case TimeChoice.quick:
        return '15 minutes';
      case TimeChoice.solid:
        return '1 hour';
      case TimeChoice.deep:
        return 'as long as needed';
    }
  }

  String get displayLabel {
    switch (this) {
      case TimeChoice.quick:
        return 'Quick Blast';
      case TimeChoice.solid:
        return 'Solid Session';
      case TimeChoice.deep:
        return 'Going Deep';
    }
  }

  String get subtitle {
    switch (this) {
      case TimeChoice.quick:
        return "15 minutes, let's go";
      case TimeChoice.solid:
        return 'About an hour, full send';
      case TimeChoice.deep:
        return "No limit, let's finish this";
    }
  }

  String get icon {
    switch (this) {
      case TimeChoice.quick:
        return '⚡';
      case TimeChoice.solid:
        return '🔥';
      case TimeChoice.deep:
        return '🏊';
    }
  }
}

@freezed
class AppState with _$AppState {
  const factory AppState({
    required AppScreen screen,
    required List<int> completedSteps,
    required List<PredictionHistoryItem> history,
    required int streak,
    required int totalCases,
    required int normalCases,
    required int pneumoniaCases,

    required bool isXray,
    String? photoPath,
    String? photoBase64,
    PredictionResult? result,
    required bool isLoading,
    String? error,

    // Patient Information for Current Examination
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? patientPhone,

    // Active Examination Record
    String? currentCaseId,
    String? currentPhotoURL,
    PredictionHistoryItem? currentCase,
  }) = _AppState;

  const AppState._();

  factory AppState.initial() => AppState(
    screen: AppScreen.camera,
    isXray: true,
    photoPath: null,
    photoBase64: null,
    result: null,
    completedSteps: [],
    history: [],
    streak: 0,
    normalCases: 0,
    pneumoniaCases: 0,
    totalCases: 0,
    isLoading: false,
    error: null,
    patientName: null,
    patientAge: null,
    patientGender: null,
    patientPhone: null,
    currentCaseId: null,
    currentPhotoURL: null,
    currentCase: null,
  );

  bool get hasPhoto => photoPath != null && photoBase64 != null;
  bool get hasPatientInfo =>
      patientName != null &&
      patientName!.trim().isNotEmpty &&
      patientAge != null &&
      patientPhone != null &&
      patientPhone!.trim().isNotEmpty;
  int get completedCount => completedSteps.length;
}
