// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppEventCopyWith<$Res> {
  factory $AppEventCopyWith(AppEvent value, $Res Function(AppEvent) then) =
      _$AppEventCopyWithImpl<$Res, AppEvent>;
}

/// @nodoc
class _$AppEventCopyWithImpl<$Res, $Val extends AppEvent>
    implements $AppEventCopyWith<$Res> {
  _$AppEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SetPhotoImplCopyWith<$Res> {
  factory _$$SetPhotoImplCopyWith(
    _$SetPhotoImpl value,
    $Res Function(_$SetPhotoImpl) then,
  ) = __$$SetPhotoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({File file});
}

/// @nodoc
class __$$SetPhotoImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$SetPhotoImpl>
    implements _$$SetPhotoImplCopyWith<$Res> {
  __$$SetPhotoImplCopyWithImpl(
    _$SetPhotoImpl _value,
    $Res Function(_$SetPhotoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? file = null}) {
    return _then(
      _$SetPhotoImpl(
        null == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as File,
      ),
    );
  }
}

/// @nodoc

class _$SetPhotoImpl implements SetPhoto {
  const _$SetPhotoImpl(this.file);

  @override
  final File file;

  @override
  String toString() {
    return 'AppEvent.setPhoto(file: $file)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetPhotoImpl &&
            (identical(other.file, file) || other.file == file));
  }

  @override
  int get hashCode => Object.hash(runtimeType, file);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetPhotoImplCopyWith<_$SetPhotoImpl> get copyWith =>
      __$$SetPhotoImplCopyWithImpl<_$SetPhotoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return setPhoto(file);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return setPhoto?.call(file);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (setPhoto != null) {
      return setPhoto(file);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return setPhoto(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return setPhoto?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (setPhoto != null) {
      return setPhoto(this);
    }
    return orElse();
  }
}

abstract class SetPhoto implements AppEvent {
  const factory SetPhoto(final File file) = _$SetPhotoImpl;

  File get file;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetPhotoImplCopyWith<_$SetPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SetPatientInfoImplCopyWith<$Res> {
  factory _$$SetPatientInfoImplCopyWith(
    _$SetPatientInfoImpl value,
    $Res Function(_$SetPatientInfoImpl) then,
  ) = __$$SetPatientInfoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String fullName, int age, String gender, String phone});
}

/// @nodoc
class __$$SetPatientInfoImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$SetPatientInfoImpl>
    implements _$$SetPatientInfoImplCopyWith<$Res> {
  __$$SetPatientInfoImplCopyWithImpl(
    _$SetPatientInfoImpl _value,
    $Res Function(_$SetPatientInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? age = null,
    Object? gender = null,
    Object? phone = null,
  }) {
    return _then(
      _$SetPatientInfoImpl(
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SetPatientInfoImpl implements SetPatientInfo {
  const _$SetPatientInfoImpl({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.phone,
  });

  @override
  final String fullName;
  @override
  final int age;
  @override
  final String gender;
  @override
  final String phone;

  @override
  String toString() {
    return 'AppEvent.setPatientInfo(fullName: $fullName, age: $age, gender: $gender, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetPatientInfoImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fullName, age, gender, phone);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetPatientInfoImplCopyWith<_$SetPatientInfoImpl> get copyWith =>
      __$$SetPatientInfoImplCopyWithImpl<_$SetPatientInfoImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return setPatientInfo(fullName, age, gender, phone);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return setPatientInfo?.call(fullName, age, gender, phone);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (setPatientInfo != null) {
      return setPatientInfo(fullName, age, gender, phone);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return setPatientInfo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return setPatientInfo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (setPatientInfo != null) {
      return setPatientInfo(this);
    }
    return orElse();
  }
}

abstract class SetPatientInfo implements AppEvent {
  const factory SetPatientInfo({
    required final String fullName,
    required final int age,
    required final String gender,
    required final String phone,
  }) = _$SetPatientInfoImpl;

  String get fullName;
  int get age;
  String get gender;
  String get phone;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetPatientInfoImplCopyWith<_$SetPatientInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearPatientInfoImplCopyWith<$Res> {
  factory _$$ClearPatientInfoImplCopyWith(
    _$ClearPatientInfoImpl value,
    $Res Function(_$ClearPatientInfoImpl) then,
  ) = __$$ClearPatientInfoImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearPatientInfoImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$ClearPatientInfoImpl>
    implements _$$ClearPatientInfoImplCopyWith<$Res> {
  __$$ClearPatientInfoImplCopyWithImpl(
    _$ClearPatientInfoImpl _value,
    $Res Function(_$ClearPatientInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearPatientInfoImpl implements ClearPatientInfo {
  const _$ClearPatientInfoImpl();

  @override
  String toString() {
    return 'AppEvent.clearPatientInfo()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearPatientInfoImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return clearPatientInfo();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return clearPatientInfo?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (clearPatientInfo != null) {
      return clearPatientInfo();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return clearPatientInfo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return clearPatientInfo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (clearPatientInfo != null) {
      return clearPatientInfo(this);
    }
    return orElse();
  }
}

abstract class ClearPatientInfo implements AppEvent {
  const factory ClearPatientInfo() = _$ClearPatientInfoImpl;
}

/// @nodoc
abstract class _$$GoToHistoryImplCopyWith<$Res> {
  factory _$$GoToHistoryImplCopyWith(
    _$GoToHistoryImpl value,
    $Res Function(_$GoToHistoryImpl) then,
  ) = __$$GoToHistoryImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GoToHistoryImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$GoToHistoryImpl>
    implements _$$GoToHistoryImplCopyWith<$Res> {
  __$$GoToHistoryImplCopyWithImpl(
    _$GoToHistoryImpl _value,
    $Res Function(_$GoToHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GoToHistoryImpl implements GoToHistory {
  const _$GoToHistoryImpl();

  @override
  String toString() {
    return 'AppEvent.goToHistory()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GoToHistoryImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return goToHistory();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return goToHistory?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (goToHistory != null) {
      return goToHistory();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return goToHistory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return goToHistory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (goToHistory != null) {
      return goToHistory(this);
    }
    return orElse();
  }
}

abstract class GoToHistory implements AppEvent {
  const factory GoToHistory() = _$GoToHistoryImpl;
}

/// @nodoc
abstract class _$$GoToCameraImplCopyWith<$Res> {
  factory _$$GoToCameraImplCopyWith(
    _$GoToCameraImpl value,
    $Res Function(_$GoToCameraImpl) then,
  ) = __$$GoToCameraImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GoToCameraImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$GoToCameraImpl>
    implements _$$GoToCameraImplCopyWith<$Res> {
  __$$GoToCameraImplCopyWithImpl(
    _$GoToCameraImpl _value,
    $Res Function(_$GoToCameraImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GoToCameraImpl implements GoToCamera {
  const _$GoToCameraImpl();

  @override
  String toString() {
    return 'AppEvent.goToCamera()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GoToCameraImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return goToCamera();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return goToCamera?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (goToCamera != null) {
      return goToCamera();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return goToCamera(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return goToCamera?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (goToCamera != null) {
      return goToCamera(this);
    }
    return orElse();
  }
}

abstract class GoToCamera implements AppEvent {
  const factory GoToCamera() = _$GoToCameraImpl;
}

/// @nodoc
abstract class _$$ClearErrorImplCopyWith<$Res> {
  factory _$$ClearErrorImplCopyWith(
    _$ClearErrorImpl value,
    $Res Function(_$ClearErrorImpl) then,
  ) = __$$ClearErrorImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearErrorImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$ClearErrorImpl>
    implements _$$ClearErrorImplCopyWith<$Res> {
  __$$ClearErrorImplCopyWithImpl(
    _$ClearErrorImpl _value,
    $Res Function(_$ClearErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearErrorImpl implements ClearError {
  const _$ClearErrorImpl();

  @override
  String toString() {
    return 'AppEvent.clearError()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearErrorImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return clearError();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return clearError?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (clearError != null) {
      return clearError();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return clearError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return clearError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (clearError != null) {
      return clearError(this);
    }
    return orElse();
  }
}

abstract class ClearError implements AppEvent {
  const factory ClearError() = _$ClearErrorImpl;
}

/// @nodoc
abstract class _$$AnalyzeMissionImplCopyWith<$Res> {
  factory _$$AnalyzeMissionImplCopyWith(
    _$AnalyzeMissionImpl value,
    $Res Function(_$AnalyzeMissionImpl) then,
  ) = __$$AnalyzeMissionImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AnalyzeMissionImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$AnalyzeMissionImpl>
    implements _$$AnalyzeMissionImplCopyWith<$Res> {
  __$$AnalyzeMissionImplCopyWithImpl(
    _$AnalyzeMissionImpl _value,
    $Res Function(_$AnalyzeMissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AnalyzeMissionImpl implements AnalyzeMission {
  const _$AnalyzeMissionImpl();

  @override
  String toString() {
    return 'AppEvent.analyzeMission()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AnalyzeMissionImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return analyzeMission();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return analyzeMission?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (analyzeMission != null) {
      return analyzeMission();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return analyzeMission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return analyzeMission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (analyzeMission != null) {
      return analyzeMission(this);
    }
    return orElse();
  }
}

abstract class AnalyzeMission implements AppEvent {
  const factory AnalyzeMission() = _$AnalyzeMissionImpl;
}

/// @nodoc
abstract class _$$RetryAnalysisImplCopyWith<$Res> {
  factory _$$RetryAnalysisImplCopyWith(
    _$RetryAnalysisImpl value,
    $Res Function(_$RetryAnalysisImpl) then,
  ) = __$$RetryAnalysisImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RetryAnalysisImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$RetryAnalysisImpl>
    implements _$$RetryAnalysisImplCopyWith<$Res> {
  __$$RetryAnalysisImplCopyWithImpl(
    _$RetryAnalysisImpl _value,
    $Res Function(_$RetryAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RetryAnalysisImpl implements RetryAnalysis {
  const _$RetryAnalysisImpl();

  @override
  String toString() {
    return 'AppEvent.retryAnalysis()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RetryAnalysisImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return retryAnalysis();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return retryAnalysis?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (retryAnalysis != null) {
      return retryAnalysis();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return retryAnalysis(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return retryAnalysis?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (retryAnalysis != null) {
      return retryAnalysis(this);
    }
    return orElse();
  }
}

abstract class RetryAnalysis implements AppEvent {
  const factory RetryAnalysis() = _$RetryAnalysisImpl;
}

/// @nodoc
abstract class _$$CompleteMissionImplCopyWith<$Res> {
  factory _$$CompleteMissionImplCopyWith(
    _$CompleteMissionImpl value,
    $Res Function(_$CompleteMissionImpl) then,
  ) = __$$CompleteMissionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isXray});
}

/// @nodoc
class __$$CompleteMissionImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$CompleteMissionImpl>
    implements _$$CompleteMissionImplCopyWith<$Res> {
  __$$CompleteMissionImplCopyWithImpl(
    _$CompleteMissionImpl _value,
    $Res Function(_$CompleteMissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isXray = null}) {
    return _then(
      _$CompleteMissionImpl(
        null == isXray
            ? _value.isXray
            : isXray // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CompleteMissionImpl implements CompleteMission {
  const _$CompleteMissionImpl(this.isXray);

  @override
  final bool isXray;

  @override
  String toString() {
    return 'AppEvent.completeMission(isXray: $isXray)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteMissionImpl &&
            (identical(other.isXray, isXray) || other.isXray == isXray));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isXray);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteMissionImplCopyWith<_$CompleteMissionImpl> get copyWith =>
      __$$CompleteMissionImplCopyWithImpl<_$CompleteMissionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File file) setPhoto,
    required TResult Function(
      String fullName,
      int age,
      String gender,
      String phone,
    )
    setPatientInfo,
    required TResult Function() clearPatientInfo,
    required TResult Function() goToHistory,
    required TResult Function() goToCamera,
    required TResult Function() clearError,
    required TResult Function() analyzeMission,
    required TResult Function() retryAnalysis,
    required TResult Function(bool isXray) completeMission,
  }) {
    return completeMission(isXray);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File file)? setPhoto,
    TResult? Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult? Function()? clearPatientInfo,
    TResult? Function()? goToHistory,
    TResult? Function()? goToCamera,
    TResult? Function()? clearError,
    TResult? Function()? analyzeMission,
    TResult? Function()? retryAnalysis,
    TResult? Function(bool isXray)? completeMission,
  }) {
    return completeMission?.call(isXray);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File file)? setPhoto,
    TResult Function(String fullName, int age, String gender, String phone)?
    setPatientInfo,
    TResult Function()? clearPatientInfo,
    TResult Function()? goToHistory,
    TResult Function()? goToCamera,
    TResult Function()? clearError,
    TResult Function()? analyzeMission,
    TResult Function()? retryAnalysis,
    TResult Function(bool isXray)? completeMission,
    required TResult orElse(),
  }) {
    if (completeMission != null) {
      return completeMission(isXray);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SetPhoto value) setPhoto,
    required TResult Function(SetPatientInfo value) setPatientInfo,
    required TResult Function(ClearPatientInfo value) clearPatientInfo,
    required TResult Function(GoToHistory value) goToHistory,
    required TResult Function(GoToCamera value) goToCamera,
    required TResult Function(ClearError value) clearError,
    required TResult Function(AnalyzeMission value) analyzeMission,
    required TResult Function(RetryAnalysis value) retryAnalysis,
    required TResult Function(CompleteMission value) completeMission,
  }) {
    return completeMission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SetPhoto value)? setPhoto,
    TResult? Function(SetPatientInfo value)? setPatientInfo,
    TResult? Function(ClearPatientInfo value)? clearPatientInfo,
    TResult? Function(GoToHistory value)? goToHistory,
    TResult? Function(GoToCamera value)? goToCamera,
    TResult? Function(ClearError value)? clearError,
    TResult? Function(AnalyzeMission value)? analyzeMission,
    TResult? Function(RetryAnalysis value)? retryAnalysis,
    TResult? Function(CompleteMission value)? completeMission,
  }) {
    return completeMission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SetPhoto value)? setPhoto,
    TResult Function(SetPatientInfo value)? setPatientInfo,
    TResult Function(ClearPatientInfo value)? clearPatientInfo,
    TResult Function(GoToHistory value)? goToHistory,
    TResult Function(GoToCamera value)? goToCamera,
    TResult Function(ClearError value)? clearError,
    TResult Function(AnalyzeMission value)? analyzeMission,
    TResult Function(RetryAnalysis value)? retryAnalysis,
    TResult Function(CompleteMission value)? completeMission,
    required TResult orElse(),
  }) {
    if (completeMission != null) {
      return completeMission(this);
    }
    return orElse();
  }
}

abstract class CompleteMission implements AppEvent {
  const factory CompleteMission(final bool isXray) = _$CompleteMissionImpl;

  bool get isXray;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteMissionImplCopyWith<_$CompleteMissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
