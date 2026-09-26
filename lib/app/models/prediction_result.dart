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

@JsonSerializable()
@freezed
class PredictionHistoryItem with _$PredictionHistoryItem {
  const factory PredictionHistoryItem({
    required String label,
    required double probability,
    required bool isPneumonia,
    required DateTime completedAt,
    required String photoPath,
  }) = _PredictionHistoryItem;

  const PredictionHistoryItem._();

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    return _$PredictionHistoryItemFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PredictionHistoryItemToJson(this);
}
