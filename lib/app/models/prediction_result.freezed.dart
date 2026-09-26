// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prediction_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PredictionResult {
  String get label => throw _privateConstructorUsedError;
  double get probability => throw _privateConstructorUsedError;
  bool get isPneumonia => throw _privateConstructorUsedError;

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictionResultCopyWith<PredictionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionResultCopyWith<$Res> {
  factory $PredictionResultCopyWith(
    PredictionResult value,
    $Res Function(PredictionResult) then,
  ) = _$PredictionResultCopyWithImpl<$Res, PredictionResult>;
  @useResult
  $Res call({String label, double probability, bool isPneumonia});
}

/// @nodoc
class _$PredictionResultCopyWithImpl<$Res, $Val extends PredictionResult>
    implements $PredictionResultCopyWith<$Res> {
  _$PredictionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? probability = null,
    Object? isPneumonia = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            probability: null == probability
                ? _value.probability
                : probability // ignore: cast_nullable_to_non_nullable
                      as double,
            isPneumonia: null == isPneumonia
                ? _value.isPneumonia
                : isPneumonia // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PredictionResultImplCopyWith<$Res>
    implements $PredictionResultCopyWith<$Res> {
  factory _$$PredictionResultImplCopyWith(
    _$PredictionResultImpl value,
    $Res Function(_$PredictionResultImpl) then,
  ) = __$$PredictionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double probability, bool isPneumonia});
}

/// @nodoc
class __$$PredictionResultImplCopyWithImpl<$Res>
    extends _$PredictionResultCopyWithImpl<$Res, _$PredictionResultImpl>
    implements _$$PredictionResultImplCopyWith<$Res> {
  __$$PredictionResultImplCopyWithImpl(
    _$PredictionResultImpl _value,
    $Res Function(_$PredictionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? probability = null,
    Object? isPneumonia = null,
  }) {
    return _then(
      _$PredictionResultImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        probability: null == probability
            ? _value.probability
            : probability // ignore: cast_nullable_to_non_nullable
                  as double,
        isPneumonia: null == isPneumonia
            ? _value.isPneumonia
            : isPneumonia // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PredictionResultImpl extends _PredictionResult {
  const _$PredictionResultImpl({
    required this.label,
    required this.probability,
    required this.isPneumonia,
  }) : super._();

  @override
  final String label;
  @override
  final double probability;
  @override
  final bool isPneumonia;

  @override
  String toString() {
    return 'PredictionResult(label: $label, probability: $probability, isPneumonia: $isPneumonia)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionResultImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.isPneumonia, isPneumonia) ||
                other.isPneumonia == isPneumonia));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, probability, isPneumonia);

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionResultImplCopyWith<_$PredictionResultImpl> get copyWith =>
      __$$PredictionResultImplCopyWithImpl<_$PredictionResultImpl>(
        this,
        _$identity,
      );
}

abstract class _PredictionResult extends PredictionResult {
  const factory _PredictionResult({
    required final String label,
    required final double probability,
    required final bool isPneumonia,
  }) = _$PredictionResultImpl;
  const _PredictionResult._() : super._();

  @override
  String get label;
  @override
  double get probability;
  @override
  bool get isPneumonia;

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictionResultImplCopyWith<_$PredictionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PredictionHistoryItem {
  String get label => throw _privateConstructorUsedError;
  double get probability => throw _privateConstructorUsedError;
  bool get isPneumonia => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String get photoPath => throw _privateConstructorUsedError;

  /// Create a copy of PredictionHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictionHistoryItemCopyWith<PredictionHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionHistoryItemCopyWith<$Res> {
  factory $PredictionHistoryItemCopyWith(
    PredictionHistoryItem value,
    $Res Function(PredictionHistoryItem) then,
  ) = _$PredictionHistoryItemCopyWithImpl<$Res, PredictionHistoryItem>;
  @useResult
  $Res call({
    String label,
    double probability,
    bool isPneumonia,
    DateTime completedAt,
    String photoPath,
  });
}

/// @nodoc
class _$PredictionHistoryItemCopyWithImpl<
  $Res,
  $Val extends PredictionHistoryItem
>
    implements $PredictionHistoryItemCopyWith<$Res> {
  _$PredictionHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictionHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? probability = null,
    Object? isPneumonia = null,
    Object? completedAt = null,
    Object? photoPath = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            probability: null == probability
                ? _value.probability
                : probability // ignore: cast_nullable_to_non_nullable
                      as double,
            isPneumonia: null == isPneumonia
                ? _value.isPneumonia
                : isPneumonia // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            photoPath: null == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PredictionHistoryItemImplCopyWith<$Res>
    implements $PredictionHistoryItemCopyWith<$Res> {
  factory _$$PredictionHistoryItemImplCopyWith(
    _$PredictionHistoryItemImpl value,
    $Res Function(_$PredictionHistoryItemImpl) then,
  ) = __$$PredictionHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String label,
    double probability,
    bool isPneumonia,
    DateTime completedAt,
    String photoPath,
  });
}

/// @nodoc
class __$$PredictionHistoryItemImplCopyWithImpl<$Res>
    extends
        _$PredictionHistoryItemCopyWithImpl<$Res, _$PredictionHistoryItemImpl>
    implements _$$PredictionHistoryItemImplCopyWith<$Res> {
  __$$PredictionHistoryItemImplCopyWithImpl(
    _$PredictionHistoryItemImpl _value,
    $Res Function(_$PredictionHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PredictionHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? probability = null,
    Object? isPneumonia = null,
    Object? completedAt = null,
    Object? photoPath = null,
  }) {
    return _then(
      _$PredictionHistoryItemImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        probability: null == probability
            ? _value.probability
            : probability // ignore: cast_nullable_to_non_nullable
                  as double,
        isPneumonia: null == isPneumonia
            ? _value.isPneumonia
            : isPneumonia // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        photoPath: null == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PredictionHistoryItemImpl extends _PredictionHistoryItem {
  const _$PredictionHistoryItemImpl({
    required this.label,
    required this.probability,
    required this.isPneumonia,
    required this.completedAt,
    required this.photoPath,
  }) : super._();

  @override
  final String label;
  @override
  final double probability;
  @override
  final bool isPneumonia;
  @override
  final DateTime completedAt;
  @override
  final String photoPath;

  @override
  String toString() {
    return 'PredictionHistoryItem(label: $label, probability: $probability, isPneumonia: $isPneumonia, completedAt: $completedAt, photoPath: $photoPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionHistoryItemImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.isPneumonia, isPneumonia) ||
                other.isPneumonia == isPneumonia) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    label,
    probability,
    isPneumonia,
    completedAt,
    photoPath,
  );

  /// Create a copy of PredictionHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionHistoryItemImplCopyWith<_$PredictionHistoryItemImpl>
  get copyWith =>
      __$$PredictionHistoryItemImplCopyWithImpl<_$PredictionHistoryItemImpl>(
        this,
        _$identity,
      );
}

abstract class _PredictionHistoryItem extends PredictionHistoryItem {
  const factory _PredictionHistoryItem({
    required final String label,
    required final double probability,
    required final bool isPneumonia,
    required final DateTime completedAt,
    required final String photoPath,
  }) = _$PredictionHistoryItemImpl;
  const _PredictionHistoryItem._() : super._();

  @override
  String get label;
  @override
  double get probability;
  @override
  bool get isPneumonia;
  @override
  DateTime get completedAt;
  @override
  String get photoPath;

  /// Create a copy of PredictionHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictionHistoryItemImplCopyWith<_$PredictionHistoryItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}
