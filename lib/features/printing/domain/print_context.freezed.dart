// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'print_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrintContext {

 String get userName; String get organizationName; String get organizationEmail; String get organizationPhone; String get logoAssetPath; DateTime get printDate;
/// Create a copy of PrintContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrintContextCopyWith<PrintContext> get copyWith => _$PrintContextCopyWithImpl<PrintContext>(this as PrintContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrintContext&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.organizationEmail, organizationEmail) || other.organizationEmail == organizationEmail)&&(identical(other.organizationPhone, organizationPhone) || other.organizationPhone == organizationPhone)&&(identical(other.logoAssetPath, logoAssetPath) || other.logoAssetPath == logoAssetPath)&&(identical(other.printDate, printDate) || other.printDate == printDate));
}


@override
int get hashCode => Object.hash(runtimeType,userName,organizationName,organizationEmail,organizationPhone,logoAssetPath,printDate);

@override
String toString() {
  return 'PrintContext(userName: $userName, organizationName: $organizationName, organizationEmail: $organizationEmail, organizationPhone: $organizationPhone, logoAssetPath: $logoAssetPath, printDate: $printDate)';
}


}

/// @nodoc
abstract mixin class $PrintContextCopyWith<$Res>  {
  factory $PrintContextCopyWith(PrintContext value, $Res Function(PrintContext) _then) = _$PrintContextCopyWithImpl;
@useResult
$Res call({
 String userName, String organizationName, String organizationEmail, String organizationPhone, String logoAssetPath, DateTime printDate
});




}
/// @nodoc
class _$PrintContextCopyWithImpl<$Res>
    implements $PrintContextCopyWith<$Res> {
  _$PrintContextCopyWithImpl(this._self, this._then);

  final PrintContext _self;
  final $Res Function(PrintContext) _then;

/// Create a copy of PrintContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? organizationName = null,Object? organizationEmail = null,Object? organizationPhone = null,Object? logoAssetPath = null,Object? printDate = null,}) {
  return _then(_self.copyWith(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,organizationEmail: null == organizationEmail ? _self.organizationEmail : organizationEmail // ignore: cast_nullable_to_non_nullable
as String,organizationPhone: null == organizationPhone ? _self.organizationPhone : organizationPhone // ignore: cast_nullable_to_non_nullable
as String,logoAssetPath: null == logoAssetPath ? _self.logoAssetPath : logoAssetPath // ignore: cast_nullable_to_non_nullable
as String,printDate: null == printDate ? _self.printDate : printDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrintContext].
extension PrintContextPatterns on PrintContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrintContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrintContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrintContext value)  $default,){
final _that = this;
switch (_that) {
case _PrintContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrintContext value)?  $default,){
final _that = this;
switch (_that) {
case _PrintContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  String organizationName,  String organizationEmail,  String organizationPhone,  String logoAssetPath,  DateTime printDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrintContext() when $default != null:
return $default(_that.userName,_that.organizationName,_that.organizationEmail,_that.organizationPhone,_that.logoAssetPath,_that.printDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  String organizationName,  String organizationEmail,  String organizationPhone,  String logoAssetPath,  DateTime printDate)  $default,) {final _that = this;
switch (_that) {
case _PrintContext():
return $default(_that.userName,_that.organizationName,_that.organizationEmail,_that.organizationPhone,_that.logoAssetPath,_that.printDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  String organizationName,  String organizationEmail,  String organizationPhone,  String logoAssetPath,  DateTime printDate)?  $default,) {final _that = this;
switch (_that) {
case _PrintContext() when $default != null:
return $default(_that.userName,_that.organizationName,_that.organizationEmail,_that.organizationPhone,_that.logoAssetPath,_that.printDate);case _:
  return null;

}
}

}

/// @nodoc


class _PrintContext extends PrintContext {
  const _PrintContext({required this.userName, required this.organizationName, required this.organizationEmail, required this.organizationPhone, required this.logoAssetPath, required this.printDate}): super._();
  

@override final  String userName;
@override final  String organizationName;
@override final  String organizationEmail;
@override final  String organizationPhone;
@override final  String logoAssetPath;
@override final  DateTime printDate;

/// Create a copy of PrintContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrintContextCopyWith<_PrintContext> get copyWith => __$PrintContextCopyWithImpl<_PrintContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrintContext&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.organizationEmail, organizationEmail) || other.organizationEmail == organizationEmail)&&(identical(other.organizationPhone, organizationPhone) || other.organizationPhone == organizationPhone)&&(identical(other.logoAssetPath, logoAssetPath) || other.logoAssetPath == logoAssetPath)&&(identical(other.printDate, printDate) || other.printDate == printDate));
}


@override
int get hashCode => Object.hash(runtimeType,userName,organizationName,organizationEmail,organizationPhone,logoAssetPath,printDate);

@override
String toString() {
  return 'PrintContext(userName: $userName, organizationName: $organizationName, organizationEmail: $organizationEmail, organizationPhone: $organizationPhone, logoAssetPath: $logoAssetPath, printDate: $printDate)';
}


}

/// @nodoc
abstract mixin class _$PrintContextCopyWith<$Res> implements $PrintContextCopyWith<$Res> {
  factory _$PrintContextCopyWith(_PrintContext value, $Res Function(_PrintContext) _then) = __$PrintContextCopyWithImpl;
@override @useResult
$Res call({
 String userName, String organizationName, String organizationEmail, String organizationPhone, String logoAssetPath, DateTime printDate
});




}
/// @nodoc
class __$PrintContextCopyWithImpl<$Res>
    implements _$PrintContextCopyWith<$Res> {
  __$PrintContextCopyWithImpl(this._self, this._then);

  final _PrintContext _self;
  final $Res Function(_PrintContext) _then;

/// Create a copy of PrintContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? organizationName = null,Object? organizationEmail = null,Object? organizationPhone = null,Object? logoAssetPath = null,Object? printDate = null,}) {
  return _then(_PrintContext(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,organizationEmail: null == organizationEmail ? _self.organizationEmail : organizationEmail // ignore: cast_nullable_to_non_nullable
as String,organizationPhone: null == organizationPhone ? _self.organizationPhone : organizationPhone // ignore: cast_nullable_to_non_nullable
as String,logoAssetPath: null == logoAssetPath ? _self.logoAssetPath : logoAssetPath // ignore: cast_nullable_to_non_nullable
as String,printDate: null == printDate ? _self.printDate : printDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
