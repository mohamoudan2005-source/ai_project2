// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionResult _$PredictionResultFromJson(Map<String, dynamic> json) =>
    PredictionResult(
      label: json['label'] as String,
      probability: (json['probability'] as num).toDouble(),
      isPneumonia: json['isPneumonia'] as bool,
    );

Map<String, dynamic> _$PredictionResultToJson(PredictionResult instance) =>
    <String, dynamic>{
      'label': instance.label,
      'probability': instance.probability,
      'isPneumonia': instance.isPneumonia,
    };

PredictionHistoryItem _$PredictionHistoryItemFromJson(
  Map<String, dynamic> json,
) => PredictionHistoryItem(
  label: json['label'] as String,
  probability: (json['probability'] as num).toDouble(),
  isPneumonia: json['isPneumonia'] as bool,
  completedAt: DateTime.parse(json['completedAt'] as String),
  photoPath: json['photoPath'] as String,
);

Map<String, dynamic> _$PredictionHistoryItemToJson(
  PredictionHistoryItem instance,
) => <String, dynamic>{
  'label': instance.label,
  'probability': instance.probability,
  'isPneumonia': instance.isPneumonia,
  'completedAt': instance.completedAt.toIso8601String(),
  'photoPath': instance.photoPath,
};
