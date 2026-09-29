import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_event.freezed.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.setPhoto(File file) = SetPhoto;
  const factory AppEvent.setPatientInfo({
    required String fullName,
    required int age,
    required String gender,
    required String phone,
  }) = SetPatientInfo;
  const factory AppEvent.clearPatientInfo() = ClearPatientInfo;
  const factory AppEvent.goToHistory() = GoToHistory;
  const factory AppEvent.goToCamera() = GoToCamera;
  const factory AppEvent.clearError() = ClearError;
  const factory AppEvent.analyzeMission() = AnalyzeMission;
  const factory AppEvent.retryAnalysis() = RetryAnalysis;
  const factory AppEvent.completeMission(bool isXray) = CompleteMission;
}
