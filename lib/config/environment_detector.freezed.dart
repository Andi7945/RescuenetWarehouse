// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment_detector.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EnvironmentDetectionResult {

/// Actual organization detected from Firebase project ID
 String get actualOrg;/// Actual environment detected from Firebase project ID
 String get actualEnv;/// Organization claimed via build-time --dart-define
 String get claimedOrg;/// Environment claimed via build-time --dart-define
 String get claimedEnv;/// Whether actual and claimed environments match
 bool get isMatch;/// Warning message if there's a mismatch or unknown project
 String? get warningMessage;
/// Create a copy of EnvironmentDetectionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvironmentDetectionResultCopyWith<EnvironmentDetectionResult> get copyWith => _$EnvironmentDetectionResultCopyWithImpl<EnvironmentDetectionResult>(this as EnvironmentDetectionResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvironmentDetectionResult&&(identical(other.actualOrg, actualOrg) || other.actualOrg == actualOrg)&&(identical(other.actualEnv, actualEnv) || other.actualEnv == actualEnv)&&(identical(other.claimedOrg, claimedOrg) || other.claimedOrg == claimedOrg)&&(identical(other.claimedEnv, claimedEnv) || other.claimedEnv == claimedEnv)&&(identical(other.isMatch, isMatch) || other.isMatch == isMatch)&&(identical(other.warningMessage, warningMessage) || other.warningMessage == warningMessage));
}


@override
int get hashCode => Object.hash(runtimeType,actualOrg,actualEnv,claimedOrg,claimedEnv,isMatch,warningMessage);

@override
String toString() {
  return 'EnvironmentDetectionResult(actualOrg: $actualOrg, actualEnv: $actualEnv, claimedOrg: $claimedOrg, claimedEnv: $claimedEnv, isMatch: $isMatch, warningMessage: $warningMessage)';
}


}

/// @nodoc
abstract mixin class $EnvironmentDetectionResultCopyWith<$Res>  {
  factory $EnvironmentDetectionResultCopyWith(EnvironmentDetectionResult value, $Res Function(EnvironmentDetectionResult) _then) = _$EnvironmentDetectionResultCopyWithImpl;
@useResult
$Res call({
 String actualOrg, String actualEnv, String claimedOrg, String claimedEnv, bool isMatch, String? warningMessage
});




}
/// @nodoc
class _$EnvironmentDetectionResultCopyWithImpl<$Res>
    implements $EnvironmentDetectionResultCopyWith<$Res> {
  _$EnvironmentDetectionResultCopyWithImpl(this._self, this._then);

  final EnvironmentDetectionResult _self;
  final $Res Function(EnvironmentDetectionResult) _then;

/// Create a copy of EnvironmentDetectionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actualOrg = null,Object? actualEnv = null,Object? claimedOrg = null,Object? claimedEnv = null,Object? isMatch = null,Object? warningMessage = freezed,}) {
  return _then(_self.copyWith(
actualOrg: null == actualOrg ? _self.actualOrg : actualOrg // ignore: cast_nullable_to_non_nullable
as String,actualEnv: null == actualEnv ? _self.actualEnv : actualEnv // ignore: cast_nullable_to_non_nullable
as String,claimedOrg: null == claimedOrg ? _self.claimedOrg : claimedOrg // ignore: cast_nullable_to_non_nullable
as String,claimedEnv: null == claimedEnv ? _self.claimedEnv : claimedEnv // ignore: cast_nullable_to_non_nullable
as String,isMatch: null == isMatch ? _self.isMatch : isMatch // ignore: cast_nullable_to_non_nullable
as bool,warningMessage: freezed == warningMessage ? _self.warningMessage : warningMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EnvironmentDetectionResult].
extension EnvironmentDetectionResultPatterns on EnvironmentDetectionResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnvironmentDetectionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnvironmentDetectionResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnvironmentDetectionResult value)  $default,){
final _that = this;
switch (_that) {
case _EnvironmentDetectionResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnvironmentDetectionResult value)?  $default,){
final _that = this;
switch (_that) {
case _EnvironmentDetectionResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actualOrg,  String actualEnv,  String claimedOrg,  String claimedEnv,  bool isMatch,  String? warningMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnvironmentDetectionResult() when $default != null:
return $default(_that.actualOrg,_that.actualEnv,_that.claimedOrg,_that.claimedEnv,_that.isMatch,_that.warningMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actualOrg,  String actualEnv,  String claimedOrg,  String claimedEnv,  bool isMatch,  String? warningMessage)  $default,) {final _that = this;
switch (_that) {
case _EnvironmentDetectionResult():
return $default(_that.actualOrg,_that.actualEnv,_that.claimedOrg,_that.claimedEnv,_that.isMatch,_that.warningMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actualOrg,  String actualEnv,  String claimedOrg,  String claimedEnv,  bool isMatch,  String? warningMessage)?  $default,) {final _that = this;
switch (_that) {
case _EnvironmentDetectionResult() when $default != null:
return $default(_that.actualOrg,_that.actualEnv,_that.claimedOrg,_that.claimedEnv,_that.isMatch,_that.warningMessage);case _:
  return null;

}
}

}

/// @nodoc


class _EnvironmentDetectionResult extends EnvironmentDetectionResult {
  const _EnvironmentDetectionResult({required this.actualOrg, required this.actualEnv, required this.claimedOrg, required this.claimedEnv, required this.isMatch, this.warningMessage}): super._();
  

/// Actual organization detected from Firebase project ID
@override final  String actualOrg;
/// Actual environment detected from Firebase project ID
@override final  String actualEnv;
/// Organization claimed via build-time --dart-define
@override final  String claimedOrg;
/// Environment claimed via build-time --dart-define
@override final  String claimedEnv;
/// Whether actual and claimed environments match
@override final  bool isMatch;
/// Warning message if there's a mismatch or unknown project
@override final  String? warningMessage;

/// Create a copy of EnvironmentDetectionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnvironmentDetectionResultCopyWith<_EnvironmentDetectionResult> get copyWith => __$EnvironmentDetectionResultCopyWithImpl<_EnvironmentDetectionResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnvironmentDetectionResult&&(identical(other.actualOrg, actualOrg) || other.actualOrg == actualOrg)&&(identical(other.actualEnv, actualEnv) || other.actualEnv == actualEnv)&&(identical(other.claimedOrg, claimedOrg) || other.claimedOrg == claimedOrg)&&(identical(other.claimedEnv, claimedEnv) || other.claimedEnv == claimedEnv)&&(identical(other.isMatch, isMatch) || other.isMatch == isMatch)&&(identical(other.warningMessage, warningMessage) || other.warningMessage == warningMessage));
}


@override
int get hashCode => Object.hash(runtimeType,actualOrg,actualEnv,claimedOrg,claimedEnv,isMatch,warningMessage);

@override
String toString() {
  return 'EnvironmentDetectionResult(actualOrg: $actualOrg, actualEnv: $actualEnv, claimedOrg: $claimedOrg, claimedEnv: $claimedEnv, isMatch: $isMatch, warningMessage: $warningMessage)';
}


}

/// @nodoc
abstract mixin class _$EnvironmentDetectionResultCopyWith<$Res> implements $EnvironmentDetectionResultCopyWith<$Res> {
  factory _$EnvironmentDetectionResultCopyWith(_EnvironmentDetectionResult value, $Res Function(_EnvironmentDetectionResult) _then) = __$EnvironmentDetectionResultCopyWithImpl;
@override @useResult
$Res call({
 String actualOrg, String actualEnv, String claimedOrg, String claimedEnv, bool isMatch, String? warningMessage
});




}
/// @nodoc
class __$EnvironmentDetectionResultCopyWithImpl<$Res>
    implements _$EnvironmentDetectionResultCopyWith<$Res> {
  __$EnvironmentDetectionResultCopyWithImpl(this._self, this._then);

  final _EnvironmentDetectionResult _self;
  final $Res Function(_EnvironmentDetectionResult) _then;

/// Create a copy of EnvironmentDetectionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actualOrg = null,Object? actualEnv = null,Object? claimedOrg = null,Object? claimedEnv = null,Object? isMatch = null,Object? warningMessage = freezed,}) {
  return _then(_EnvironmentDetectionResult(
actualOrg: null == actualOrg ? _self.actualOrg : actualOrg // ignore: cast_nullable_to_non_nullable
as String,actualEnv: null == actualEnv ? _self.actualEnv : actualEnv // ignore: cast_nullable_to_non_nullable
as String,claimedOrg: null == claimedOrg ? _self.claimedOrg : claimedOrg // ignore: cast_nullable_to_non_nullable
as String,claimedEnv: null == claimedEnv ? _self.claimedEnv : claimedEnv // ignore: cast_nullable_to_non_nullable
as String,isMatch: null == isMatch ? _self.isMatch : isMatch // ignore: cast_nullable_to_non_nullable
as bool,warningMessage: freezed == warningMessage ? _self.warningMessage : warningMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
