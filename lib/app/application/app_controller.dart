import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/application/app_state.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/services/ai_service.dart';
import 'package:ai_project/app/services/db_service.dart';
import 'package:ai_project/services/storage_service.dart';

class AppController extends StateNotifier<AppState> {
  final AiService _aiService;
  final DBService _storageService;
  final StorageService _firebaseStorageService;

  AppController(
    this._aiService,
    this._storageService,
    this._firebaseStorageService,
  ) : super(AppState.initial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final results = await Future.wait([
        _storageService.loadHistory(),
        _storageService.loadStreak(),
      ]);

      List<PredictionHistoryItem> totalCases =
          results[0] as List<PredictionHistoryItem>;
      List<PredictionHistoryItem> normalCases = totalCases
          .where((item) => !item.isPneumonia)
          .toList();
      List<PredictionHistoryItem> pneumoniaCases = totalCases
          .where((item) => item.isPneumonia)
          .toList();
      state = state.copyWith(
        history: totalCases,
        totalCases: totalCases.length,
        normalCases: normalCases.length,
        pneumoniaCases: pneumoniaCases.length,
        streak: results[1] as int,
      );
    } catch (_) {
      // Unauthenticated state at initial app startup; reloaded upon sign-in.
    }
  }

  /// Reloads user cases and streak data for the newly authenticated user.
  Future<void> reloadUserData() async {
    await _init();
  }

  /// Resets user state to initial state when logging out.
  void resetUserData() {
    state = AppState.initial();
  }

  /// Sets or updates patient details for the upcoming or current examination.
  void setPatientInfo({
    required String fullName,
    required int age,
    required String gender,
    required String phone,
  }) {
    state = state.copyWith(
      patientName: fullName,
      patientAge: age,
      patientGender: gender,
      patientPhone: phone,
    );
  }

  /// Clears patient details when resetting for a new examination.
  void clearPatientInfo() {
    state = state.copyWith(
      patientName: null,
      patientAge: null,
      patientGender: null,
      patientPhone: null,
    );
  }

  Future<void> setPhoto({required File file}) async {
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    state = state.copyWith(
      photoPath: file.path,
      photoBase64: base64,
      screen: AppScreen.scanning,
      error: null,
    );
  }

  void goToHistory() => state = state.copyWith(screen: AppScreen.history);

  void goToCamera() => state = state.copyWith(
    screen: AppScreen.camera,
    photoPath: null,
    photoBase64: null,
    completedSteps: [],
    error: null,
    currentCase: null,
    currentCaseId: null,
    currentPhotoURL: null,
  );

  void clearError() => state = state.copyWith(error: null);

  Future<void> analyzeMission() async {
    if (state.photoBase64 == null) return;

    state = state.copyWith(
      isLoading: true,
      screen: AppScreen.scanning,
      error: null,
    );

    try {
      final imageBytes = base64Decode(state.photoBase64!);

      bool isXray = await _aiService.predictXray(imageBytes);
      final PredictionResult result = await _aiService.predict(imageBytes);

      state = state.copyWith(
        completedSteps: [],
        isLoading: false,
        result: result,
        screen: AppScreen.complete,
        isXray: isXray,
      );

      await completeMission(isXray: isXray);
    } catch (e) {
      debugPrint('AppController: Analysis error: $e');
      state = state.copyWith(
        isLoading: false,
        error: "Lung Lens had a brain freeze 🧊 Try again?",
      );
    }
  }

  Future<void> retryAnalysis() async {
    await analyzeMission();
  }

  /// Uploads the X-ray to Firebase Storage under `users/{doctorUid}/cases/{caseId}.jpg`
  /// and saves the examination record with patient details and AI result to Cloud Firestore.
  Future<void> completeMission({required bool isXray}) async {
    final String caseId = const Uuid().v4();
    String? photoURL;

    // ── 1. Upload X-Ray to Firebase Storage ─────────────────────────────────
    if (isXray && state.photoBase64 != null) {
      try {
        final imageBytes = base64Decode(state.photoBase64!);
        photoURL = await _firebaseStorageService.uploadCaseImage(
          caseId: caseId,
          imageBytes: imageBytes,
        );
      } catch (e) {
        debugPrint('AppController: Storage upload notice: $e');
      }
    }

    // ── 2. Construct Examination Record ─────────────────────────────────────
    final result = PredictionHistoryItem(
      id: caseId,
      patientName: state.patientName,
      patientAge: state.patientAge,
      patientGender: state.patientGender,
      patientPhone: state.patientPhone,
      photoPath: state.photoPath ?? '',
      photoURL: photoURL,
      completedAt: DateTime.now(),
      label: state.result!.label,
      probability: state.result!.probability,
      isPneumonia: state.result!.isPneumonia,
    );

    // ── 3. Persist in Firestore ─────────────────────────────────────────────
    if (isXray) {
      final newHistory = [result, ...state.history];
      final newStreak = state.streak + 1;
      List<PredictionHistoryItem> normalCases = newHistory
          .where((item) => !item.isPneumonia)
          .toList();
      List<PredictionHistoryItem> pneumoniaCases = newHistory
          .where((item) => item.isPneumonia)
          .toList();

      await Future.wait([
        _storageService.saveCase(result, explicitCaseId: caseId),
        _storageService.saveStreak(newStreak),
      ]);

      state = state.copyWith(
        history: newHistory,
        streak: newStreak,
        totalCases: newHistory.length,
        normalCases: normalCases.length,
        pneumoniaCases: pneumoniaCases.length,
        currentCaseId: caseId,
        currentPhotoURL: photoURL,
        currentCase: result,
      );
    }
  }

  /// Updates patient details on an existing case and persists to Firestore.
  Future<void> updateCurrentCasePatientInfo({
    required String fullName,
    required int age,
    required String gender,
    required String phone,
  }) async {
    setPatientInfo(
      fullName: fullName,
      age: age,
      gender: gender,
      phone: phone,
    );

    final current = state.currentCase;
    if (current != null && current.id != null) {
      final updatedCase = current.copyWith(
        patientName: fullName,
        patientAge: age,
        patientGender: gender,
        patientPhone: phone,
      );

      await _storageService.saveCase(updatedCase, explicitCaseId: current.id);

      final updatedHistory = state.history.map((c) {
        return c.id == current.id ? updatedCase : c;
      }).toList();

      state = state.copyWith(
        currentCase: updatedCase,
        history: updatedHistory,
      );
    }
  }

  Future<void> mapEventToState(AppEvent event) async {
    event.when(
      setPhoto: (file) => setPhoto(file: file),
      setPatientInfo: (fullName, age, gender, phone) => setPatientInfo(
        fullName: fullName,
        age: age,
        gender: gender,
        phone: phone,
      ),
      clearPatientInfo: clearPatientInfo,
      goToHistory: goToHistory,
      goToCamera: goToCamera,
      clearError: clearError,
      analyzeMission: () => analyzeMission(),
      retryAnalysis: retryAnalysis,
      completeMission: (isXray) => completeMission(isXray: isXray),
    );
  }
}
