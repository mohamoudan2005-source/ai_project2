import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'prediction_result.freezed.dart';
part 'prediction_result.g.dart';

@JsonSerializable()
@freezed
class PredictionResult with _$PredictionResult {
  const factory PredictionResult({
    required String label,
    required double probability,
    required bool isPneumonia,
  }) = _PredictionResult;

  const PredictionResult._();

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return _$PredictionResultFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PredictionResultToJson(this);

  double get percentage => probability * 100;
}

@freezed
class PredictionHistoryItem with _$PredictionHistoryItem {
  const factory PredictionHistoryItem({
    String? id,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? patientPhone,
    required String label,
    required double probability,
    required bool isPneumonia,
    required DateTime completedAt,
    @Default('') String photoPath,
    String? photoURL,
  }) = _PredictionHistoryItem;

  const PredictionHistoryItem._();

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryItem(
      id: json['id'] as String?,
      patientName: json['patientName'] as String?,
      patientAge: (json['patientAge'] as num?)?.toInt(),
      patientGender: json['patientGender'] as String?,
      patientPhone: json['patientPhone'] as String?,
      label: json['label'] as String? ?? 'Unknown',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      isPneumonia: json['isPneumonia'] as bool? ?? false,
      completedAt: _parseDateTime(json['completedAt']),
      photoPath: json['photoPath'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patientName': patientName ?? '',
      if (patientAge != null) 'patientAge': patientAge,
      'patientGender': patientGender ?? '',
      'patientPhone': patientPhone ?? '',
      'label': label,
      'probability': probability,
      'isPneumonia': isPneumonia,
      'completedAt': completedAt.toIso8601String(),
      'photoPath': photoPath,
      if (photoURL != null) 'photoURL': photoURL,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
