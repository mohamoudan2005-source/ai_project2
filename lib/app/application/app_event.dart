import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ai_project/app/application/app_state.dart';

part 'app_event.freezed.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.setPhoto(File file) = SetPhoto;
  const factory AppEvent.goToHistory() = GoToHistory;
  const factory AppEvent.goToCamera() = GoToCamera;
  const factory AppEvent.clearError() = ClearError;
  const factory AppEvent.analyzeMission() = AnalyzeMission;
  const factory AppEvent.retryAnalysis() = RetryAnalysis;
  const factory AppEvent.completeMission(bool isXray) = CompleteMission;
}
