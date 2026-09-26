// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppState {
  AppScreen get screen => throw _privateConstructorUsedError;
  List<int> get completedSteps => throw _privateConstructorUsedError;
  List<PredictionHistoryItem> get history => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get totalCases => throw _privateConstructorUsedError;
  int get normalCases => throw _privateConstructorUsedError;
  int get pneumoniaCases => throw _privateConstructorUsedError;
  bool get isXray => throw _privateConstructorUsedError;
  String? get photoPath => throw _privateConstructorUsedError;
  String? get photoBase64 => throw _privateConstructorUsedError;
  PredictionResult? get result => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppStateCopyWith<AppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
  @useResult
  $Res call({
    AppScreen screen,
    List<int> completedSteps,
    List<PredictionHistoryItem> history,
    int streak,
    int totalCases,
    int normalCases,
    int pneumoniaCases,
    bool isXray,
    String? photoPath,
    String? photoBase64,
    PredictionResult? result,
    bool isLoading,
    String? error,
  });

  $PredictionResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? screen = null,
    Object? completedSteps = null,
    Object? history = null,
    Object? streak = null,
    Object? totalCases = null,
    Object? normalCases = null,
    Object? pneumoniaCases = null,
    Object? isXray = null,
    Object? photoPath = freezed,
    Object? photoBase64 = freezed,
    Object? result = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            screen: null == screen
                ? _value.screen
                : screen // ignore: cast_nullable_to_non_nullable
                      as AppScreen,
            completedSteps: null == completedSteps
                ? _value.completedSteps
                : completedSteps // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<PredictionHistoryItem>,
            streak: null == streak
                ? _value.streak
                : streak // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCases: null == totalCases
                ? _value.totalCases
                : totalCases // ignore: cast_nullable_to_non_nullable
                      as int,
            normalCases: null == normalCases
                ? _value.normalCases
                : normalCases // ignore: cast_nullable_to_non_nullable
                      as int,
            pneumoniaCases: null == pneumoniaCases
                ? _value.pneumoniaCases
                : pneumoniaCases // ignore: cast_nullable_to_non_nullable
                      as int,
            isXray: null == isXray
                ? _value.isXray
                : isXray // ignore: cast_nullable_to_non_nullable
                      as bool,
            photoPath: freezed == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoBase64: freezed == photoBase64
                ? _value.photoBase64
                : photoBase64 // ignore: cast_nullable_to_non_nullable
                      as String?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as PredictionResult?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PredictionResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $PredictionResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppStateImplCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$$AppStateImplCopyWith(
    _$AppStateImpl value,
    $Res Function(_$AppStateImpl) then,
  ) = __$$AppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AppScreen screen,
    List<int> completedSteps,
    List<PredictionHistoryItem> history,
    int streak,
    int totalCases,
    int normalCases,
    int pneumoniaCases,
    bool isXray,
    String? photoPath,
    String? photoBase64,
    PredictionResult? result,
    bool isLoading,
    String? error,
  });

  @override
  $PredictionResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$AppStateImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$AppStateImpl>
    implements _$$AppStateImplCopyWith<$Res> {
  __$$AppStateImplCopyWithImpl(
    _$AppStateImpl _value,
    $Res Function(_$AppStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? screen = null,
    Object? completedSteps = null,
    Object? history = null,
    Object? streak = null,
    Object? totalCases = null,
    Object? normalCases = null,
    Object? pneumoniaCases = null,
    Object? isXray = null,
    Object? photoPath = freezed,
    Object? photoBase64 = freezed,
    Object? result = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$AppStateImpl(
        screen: null == screen
            ? _value.screen
            : screen // ignore: cast_nullable_to_non_nullable
                  as AppScreen,
        completedSteps: null == completedSteps
            ? _value._completedSteps
            : completedSteps // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<PredictionHistoryItem>,
        streak: null == streak
            ? _value.streak
            : streak // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCases: null == totalCases
            ? _value.totalCases
            : totalCases // ignore: cast_nullable_to_non_nullable
                  as int,
        normalCases: null == normalCases
            ? _value.normalCases
            : normalCases // ignore: cast_nullable_to_non_nullable
                  as int,
        pneumoniaCases: null == pneumoniaCases
            ? _value.pneumoniaCases
            : pneumoniaCases // ignore: cast_nullable_to_non_nullable
                  as int,
        isXray: null == isXray
            ? _value.isXray
            : isXray // ignore: cast_nullable_to_non_nullable
                  as bool,
        photoPath: freezed == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoBase64: freezed == photoBase64
            ? _value.photoBase64
            : photoBase64 // ignore: cast_nullable_to_non_nullable
                  as String?,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as PredictionResult?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AppStateImpl extends _AppState {
  const _$AppStateImpl({
    required this.screen,
    required final List<int> completedSteps,
    required final List<PredictionHistoryItem> history,
    required this.streak,
    required this.totalCases,
    required this.normalCases,
    required this.pneumoniaCases,
    required this.isXray,
    this.photoPath,
    this.photoBase64,
    this.result,
    required this.isLoading,
    this.error,
  }) : _completedSteps = completedSteps,
       _history = history,
       super._();

  @override
  final AppScreen screen;
  final List<int> _completedSteps;
  @override
  List<int> get completedSteps {
    if (_completedSteps is EqualUnmodifiableListView) return _completedSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedSteps);
  }

  final List<PredictionHistoryItem> _history;
  @override
  List<PredictionHistoryItem> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  final int streak;
  @override
  final int totalCases;
  @override
  final int normalCases;
  @override
  final int pneumoniaCases;
  @override
  final bool isXray;
  @override
  final String? photoPath;
  @override
  final String? photoBase64;
  @override
  final PredictionResult? result;
  @override
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'AppState(screen: $screen, completedSteps: $completedSteps, history: $history, streak: $streak, totalCases: $totalCases, normalCases: $normalCases, pneumoniaCases: $pneumoniaCases, isXray: $isXray, photoPath: $photoPath, photoBase64: $photoBase64, result: $result, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppStateImpl &&
            (identical(other.screen, screen) || other.screen == screen) &&
            const DeepCollectionEquality().equals(
              other._completedSteps,
              _completedSteps,
            ) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.totalCases, totalCases) ||
                other.totalCases == totalCases) &&
            (identical(other.normalCases, normalCases) ||
                other.normalCases == normalCases) &&
            (identical(other.pneumoniaCases, pneumoniaCases) ||
                other.pneumoniaCases == pneumoniaCases) &&
            (identical(other.isXray, isXray) || other.isXray == isXray) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.photoBase64, photoBase64) ||
                other.photoBase64 == photoBase64) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    screen,
    const DeepCollectionEquality().hash(_completedSteps),
    const DeepCollectionEquality().hash(_history),
    streak,
    totalCases,
    normalCases,
    pneumoniaCases,
    isXray,
    photoPath,
    photoBase64,
    result,
    isLoading,
    error,
  );

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      __$$AppStateImplCopyWithImpl<_$AppStateImpl>(this, _$identity);
}

abstract class _AppState extends AppState {
  const factory _AppState({
    required final AppScreen screen,
    required final List<int> completedSteps,
    required final List<PredictionHistoryItem> history,
    required final int streak,
    required final int totalCases,
    required final int normalCases,
    required final int pneumoniaCases,
    required final bool isXray,
    final String? photoPath,
    final String? photoBase64,
    final PredictionResult? result,
    required final bool isLoading,
    final String? error,
  }) = _$AppStateImpl;
  const _AppState._() : super._();

  @override
  AppScreen get screen;
  @override
  List<int> get completedSteps;
  @override
  List<PredictionHistoryItem> get history;
  @override
  int get streak;
  @override
  int get totalCases;
  @override
  int get normalCases;
  @override
  int get pneumoniaCases;
  @override
  bool get isXray;
  @override
  String? get photoPath;
  @override
  String? get photoBase64;
  @override
  PredictionResult? get result;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
