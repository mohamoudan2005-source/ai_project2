// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextPage,
    required TResult Function() prevPage,
    required TResult Function(int page) goToPage,
    required TResult Function() hasSeenOnboarding,
    required TResult Function() complete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextPage,
    TResult? Function()? prevPage,
    TResult? Function(int page)? goToPage,
    TResult? Function()? hasSeenOnboarding,
    TResult? Function()? complete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextPage,
    TResult Function()? prevPage,
    TResult Function(int page)? goToPage,
    TResult Function()? hasSeenOnboarding,
    TResult Function()? complete,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextPage value) nextPage,
    required TResult Function(PrevPage value) prevPage,
    required TResult Function(GoToPage value) goToPage,
    required TResult Function(HasSeenOnboarding value) hasSeenOnboarding,
    required TResult Function(Complete value) complete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextPage value)? nextPage,
    TResult? Function(PrevPage value)? prevPage,
    TResult? Function(GoToPage value)? goToPage,
    TResult? Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult? Function(Complete value)? complete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextPage value)? nextPage,
    TResult Function(PrevPage value)? prevPage,
    TResult Function(GoToPage value)? goToPage,
    TResult Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult Function(Complete value)? complete,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingEventCopyWith<$Res> {
  factory $OnboardingEventCopyWith(
    OnboardingEvent value,
    $Res Function(OnboardingEvent) then,
  ) = _$OnboardingEventCopyWithImpl<$Res, OnboardingEvent>;
}

/// @nodoc
class _$OnboardingEventCopyWithImpl<$Res, $Val extends OnboardingEvent>
    implements $OnboardingEventCopyWith<$Res> {
  _$OnboardingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NextPageImplCopyWith<$Res> {
  factory _$$NextPageImplCopyWith(
    _$NextPageImpl value,
    $Res Function(_$NextPageImpl) then,
  ) = __$$NextPageImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NextPageImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$NextPageImpl>
    implements _$$NextPageImplCopyWith<$Res> {
  __$$NextPageImplCopyWithImpl(
    _$NextPageImpl _value,
    $Res Function(_$NextPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NextPageImpl implements NextPage {
  const _$NextPageImpl();

  @override
  String toString() {
    return 'OnboardingEvent.nextPage()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NextPageImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextPage,
    required TResult Function() prevPage,
    required TResult Function(int page) goToPage,
    required TResult Function() hasSeenOnboarding,
    required TResult Function() complete,
  }) {
    return nextPage();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextPage,
    TResult? Function()? prevPage,
    TResult? Function(int page)? goToPage,
    TResult? Function()? hasSeenOnboarding,
    TResult? Function()? complete,
  }) {
    return nextPage?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextPage,
    TResult Function()? prevPage,
    TResult Function(int page)? goToPage,
    TResult Function()? hasSeenOnboarding,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (nextPage != null) {
      return nextPage();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextPage value) nextPage,
    required TResult Function(PrevPage value) prevPage,
    required TResult Function(GoToPage value) goToPage,
    required TResult Function(HasSeenOnboarding value) hasSeenOnboarding,
    required TResult Function(Complete value) complete,
  }) {
    return nextPage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextPage value)? nextPage,
    TResult? Function(PrevPage value)? prevPage,
    TResult? Function(GoToPage value)? goToPage,
    TResult? Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult? Function(Complete value)? complete,
  }) {
    return nextPage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextPage value)? nextPage,
    TResult Function(PrevPage value)? prevPage,
    TResult Function(GoToPage value)? goToPage,
    TResult Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult Function(Complete value)? complete,
    required TResult orElse(),
  }) {
    if (nextPage != null) {
      return nextPage(this);
    }
    return orElse();
  }
}

abstract class NextPage implements OnboardingEvent {
  const factory NextPage() = _$NextPageImpl;
}

/// @nodoc
abstract class _$$PrevPageImplCopyWith<$Res> {
  factory _$$PrevPageImplCopyWith(
    _$PrevPageImpl value,
    $Res Function(_$PrevPageImpl) then,
  ) = __$$PrevPageImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PrevPageImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$PrevPageImpl>
    implements _$$PrevPageImplCopyWith<$Res> {
  __$$PrevPageImplCopyWithImpl(
    _$PrevPageImpl _value,
    $Res Function(_$PrevPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PrevPageImpl implements PrevPage {
  const _$PrevPageImpl();

  @override
  String toString() {
    return 'OnboardingEvent.prevPage()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PrevPageImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextPage,
    required TResult Function() prevPage,
    required TResult Function(int page) goToPage,
    required TResult Function() hasSeenOnboarding,
    required TResult Function() complete,
  }) {
    return prevPage();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextPage,
    TResult? Function()? prevPage,
    TResult? Function(int page)? goToPage,
    TResult? Function()? hasSeenOnboarding,
    TResult? Function()? complete,
  }) {
    return prevPage?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextPage,
    TResult Function()? prevPage,
    TResult Function(int page)? goToPage,
    TResult Function()? hasSeenOnboarding,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (prevPage != null) {
      return prevPage();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextPage value) nextPage,
    required TResult Function(PrevPage value) prevPage,
    required TResult Function(GoToPage value) goToPage,
    required TResult Function(HasSeenOnboarding value) hasSeenOnboarding,
    required TResult Function(Complete value) complete,
  }) {
    return prevPage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextPage value)? nextPage,
    TResult? Function(PrevPage value)? prevPage,
    TResult? Function(GoToPage value)? goToPage,
    TResult? Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult? Function(Complete value)? complete,
  }) {
    return prevPage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextPage value)? nextPage,
    TResult Function(PrevPage value)? prevPage,
    TResult Function(GoToPage value)? goToPage,
    TResult Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult Function(Complete value)? complete,
    required TResult orElse(),
  }) {
    if (prevPage != null) {
      return prevPage(this);
    }
    return orElse();
  }
}

abstract class PrevPage implements OnboardingEvent {
  const factory PrevPage() = _$PrevPageImpl;
}

/// @nodoc
abstract class _$$GoToPageImplCopyWith<$Res> {
  factory _$$GoToPageImplCopyWith(
    _$GoToPageImpl value,
    $Res Function(_$GoToPageImpl) then,
  ) = __$$GoToPageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int page});
}

/// @nodoc
class __$$GoToPageImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$GoToPageImpl>
    implements _$$GoToPageImplCopyWith<$Res> {
  __$$GoToPageImplCopyWithImpl(
    _$GoToPageImpl _value,
    $Res Function(_$GoToPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? page = null}) {
    return _then(
      _$GoToPageImpl(
        null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GoToPageImpl implements GoToPage {
  const _$GoToPageImpl(this.page);

  @override
  final int page;

  @override
  String toString() {
    return 'OnboardingEvent.goToPage(page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoToPageImpl &&
            (identical(other.page, page) || other.page == page));
  }

  @override
  int get hashCode => Object.hash(runtimeType, page);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoToPageImplCopyWith<_$GoToPageImpl> get copyWith =>
      __$$GoToPageImplCopyWithImpl<_$GoToPageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextPage,
    required TResult Function() prevPage,
    required TResult Function(int page) goToPage,
    required TResult Function() hasSeenOnboarding,
    required TResult Function() complete,
  }) {
    return goToPage(page);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextPage,
    TResult? Function()? prevPage,
    TResult? Function(int page)? goToPage,
    TResult? Function()? hasSeenOnboarding,
    TResult? Function()? complete,
  }) {
    return goToPage?.call(page);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextPage,
    TResult Function()? prevPage,
    TResult Function(int page)? goToPage,
    TResult Function()? hasSeenOnboarding,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (goToPage != null) {
      return goToPage(page);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextPage value) nextPage,
    required TResult Function(PrevPage value) prevPage,
    required TResult Function(GoToPage value) goToPage,
    required TResult Function(HasSeenOnboarding value) hasSeenOnboarding,
    required TResult Function(Complete value) complete,
  }) {
    return goToPage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextPage value)? nextPage,
    TResult? Function(PrevPage value)? prevPage,
    TResult? Function(GoToPage value)? goToPage,
    TResult? Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult? Function(Complete value)? complete,
  }) {
    return goToPage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextPage value)? nextPage,
    TResult Function(PrevPage value)? prevPage,
    TResult Function(GoToPage value)? goToPage,
    TResult Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult Function(Complete value)? complete,
    required TResult orElse(),
  }) {
    if (goToPage != null) {
      return goToPage(this);
    }
    return orElse();
  }
}

abstract class GoToPage implements OnboardingEvent {
  const factory GoToPage(final int page) = _$GoToPageImpl;

  int get page;

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoToPageImplCopyWith<_$GoToPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HasSeenOnboardingImplCopyWith<$Res> {
  factory _$$HasSeenOnboardingImplCopyWith(
    _$HasSeenOnboardingImpl value,
    $Res Function(_$HasSeenOnboardingImpl) then,
  ) = __$$HasSeenOnboardingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HasSeenOnboardingImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$HasSeenOnboardingImpl>
    implements _$$HasSeenOnboardingImplCopyWith<$Res> {
  __$$HasSeenOnboardingImplCopyWithImpl(
    _$HasSeenOnboardingImpl _value,
    $Res Function(_$HasSeenOnboardingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$HasSeenOnboardingImpl implements HasSeenOnboarding {
  const _$HasSeenOnboardingImpl();

  @override
  String toString() {
    return 'OnboardingEvent.hasSeenOnboarding()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$HasSeenOnboardingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextPage,
    required TResult Function() prevPage,
    required TResult Function(int page) goToPage,
    required TResult Function() hasSeenOnboarding,
    required TResult Function() complete,
  }) {
    return hasSeenOnboarding();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextPage,
    TResult? Function()? prevPage,
    TResult? Function(int page)? goToPage,
    TResult? Function()? hasSeenOnboarding,
    TResult? Function()? complete,
  }) {
    return hasSeenOnboarding?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextPage,
    TResult Function()? prevPage,
    TResult Function(int page)? goToPage,
    TResult Function()? hasSeenOnboarding,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (hasSeenOnboarding != null) {
      return hasSeenOnboarding();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextPage value) nextPage,
    required TResult Function(PrevPage value) prevPage,
    required TResult Function(GoToPage value) goToPage,
    required TResult Function(HasSeenOnboarding value) hasSeenOnboarding,
    required TResult Function(Complete value) complete,
  }) {
    return hasSeenOnboarding(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextPage value)? nextPage,
    TResult? Function(PrevPage value)? prevPage,
    TResult? Function(GoToPage value)? goToPage,
    TResult? Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult? Function(Complete value)? complete,
  }) {
    return hasSeenOnboarding?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextPage value)? nextPage,
    TResult Function(PrevPage value)? prevPage,
    TResult Function(GoToPage value)? goToPage,
    TResult Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult Function(Complete value)? complete,
    required TResult orElse(),
  }) {
    if (hasSeenOnboarding != null) {
      return hasSeenOnboarding(this);
    }
    return orElse();
  }
}

abstract class HasSeenOnboarding implements OnboardingEvent {
  const factory HasSeenOnboarding() = _$HasSeenOnboardingImpl;
}

/// @nodoc
abstract class _$$CompleteImplCopyWith<$Res> {
  factory _$$CompleteImplCopyWith(
    _$CompleteImpl value,
    $Res Function(_$CompleteImpl) then,
  ) = __$$CompleteImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CompleteImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$CompleteImpl>
    implements _$$CompleteImplCopyWith<$Res> {
  __$$CompleteImplCopyWithImpl(
    _$CompleteImpl _value,
    $Res Function(_$CompleteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CompleteImpl implements Complete {
  const _$CompleteImpl();

  @override
  String toString() {
    return 'OnboardingEvent.complete()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CompleteImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextPage,
    required TResult Function() prevPage,
    required TResult Function(int page) goToPage,
    required TResult Function() hasSeenOnboarding,
    required TResult Function() complete,
  }) {
    return complete();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextPage,
    TResult? Function()? prevPage,
    TResult? Function(int page)? goToPage,
    TResult? Function()? hasSeenOnboarding,
    TResult? Function()? complete,
  }) {
    return complete?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextPage,
    TResult Function()? prevPage,
    TResult Function(int page)? goToPage,
    TResult Function()? hasSeenOnboarding,
    TResult Function()? complete,
    required TResult orElse(),
  }) {
    if (complete != null) {
      return complete();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextPage value) nextPage,
    required TResult Function(PrevPage value) prevPage,
    required TResult Function(GoToPage value) goToPage,
    required TResult Function(HasSeenOnboarding value) hasSeenOnboarding,
    required TResult Function(Complete value) complete,
  }) {
    return complete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextPage value)? nextPage,
    TResult? Function(PrevPage value)? prevPage,
    TResult? Function(GoToPage value)? goToPage,
    TResult? Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult? Function(Complete value)? complete,
  }) {
    return complete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextPage value)? nextPage,
    TResult Function(PrevPage value)? prevPage,
    TResult Function(GoToPage value)? goToPage,
    TResult Function(HasSeenOnboarding value)? hasSeenOnboarding,
    TResult Function(Complete value)? complete,
    required TResult orElse(),
  }) {
    if (complete != null) {
      return complete(this);
    }
    return orElse();
  }
}

abstract class Complete implements OnboardingEvent {
  const factory Complete() = _$CompleteImpl;
}
