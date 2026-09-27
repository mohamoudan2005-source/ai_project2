import 'dart:convert';
import 'dart:io';

import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/services/db_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/application/app_state.dart';
import 'package:ai_project/app/services/ai_service.dart';
import 'package:uuid/uuid.dart';

class AppController extends StateNotifier<AppState> {
  final AiService _aiService;
  final DBService _storageService;
  AppController(this._aiService, this._storageService)
    : super(AppState.initial()) {
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
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: "Lung Lens had a brain freeze 🧊 Try again?",
      );
    }
  }

  Future<void> retryAnalysis() async {
    await analyzeMission();
  }

  Future<void> completeMission({required bool isXray}) async {
    // if (state.plan == null) return;

    final result = PredictionHistoryItem(
      photoPath: state.photoPath ?? '',
      completedAt: DateTime.now(),
      label: state.result!.label,
      probability: state.result!.probability,
      isPneumonia: state.result!.isPneumonia,
    );

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
        _storageService.saveHistory(result),
        _storageService.saveStreak(newStreak),
      ]);
      state = state.copyWith(
        history: newHistory,
        streak: newStreak,
        totalCases: newHistory.length,
        normalCases: normalCases.length,
        pneumoniaCases: pneumoniaCases.length,
      );
    }
  }

  Future<void> mapEventToState(AppEvent event) async {
    event.when(
      setPhoto: (file) => setPhoto(file: file),
      goToHistory: goToHistory,
      goToCamera: goToCamera,
      clearError: clearError,
      analyzeMission: () => analyzeMission(),
      retryAnalysis: retryAnalysis,
      completeMission: (isXray) => completeMission(isXray: isXray),
    );
  }
}
