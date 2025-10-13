// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packing_dangerous_good.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PackingDangerousGood {

 String get dangerType; String get iataId; String get properShippingName; double get maxWeightPAX; double get maxWeightCargo; String get remarks; String get imagePath;
/// Create a copy of PackingDangerousGood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackingDangerousGoodCopyWith<PackingDangerousGood> get copyWith => _$PackingDangerousGoodCopyWithImpl<PackingDangerousGood>(this as PackingDangerousGood, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackingDangerousGood&&(identical(other.dangerType, dangerType) || other.dangerType == dangerType)&&(identical(other.iataId, iataId) || other.iataId == iataId)&&(identical(other.properShippingName, properShippingName) || other.properShippingName == properShippingName)&&(identical(other.maxWeightPAX, maxWeightPAX) || other.maxWeightPAX == maxWeightPAX)&&(identical(other.maxWeightCargo, maxWeightCargo) || other.maxWeightCargo == maxWeightCargo)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}


@override
int get hashCode => Object.hash(runtimeType,dangerType,iataId,properShippingName,maxWeightPAX,maxWeightCargo,remarks,imagePath);

@override
String toString() {
  return 'PackingDangerousGood(dangerType: $dangerType, iataId: $iataId, properShippingName: $properShippingName, maxWeightPAX: $maxWeightPAX, maxWeightCargo: $maxWeightCargo, remarks: $remarks, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class $PackingDangerousGoodCopyWith<$Res>  {
  factory $PackingDangerousGoodCopyWith(PackingDangerousGood value, $Res Function(PackingDangerousGood) _then) = _$PackingDangerousGoodCopyWithImpl;
@useResult
$Res call({
 String dangerType, String iataId, String properShippingName, double maxWeightPAX, double maxWeightCargo, String remarks, String imagePath
});




}
/// @nodoc
class _$PackingDangerousGoodCopyWithImpl<$Res>
    implements $PackingDangerousGoodCopyWith<$Res> {
  _$PackingDangerousGoodCopyWithImpl(this._self, this._then);

  final PackingDangerousGood _self;
  final $Res Function(PackingDangerousGood) _then;

/// Create a copy of PackingDangerousGood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dangerType = null,Object? iataId = null,Object? properShippingName = null,Object? maxWeightPAX = null,Object? maxWeightCargo = null,Object? remarks = null,Object? imagePath = null,}) {
  return _then(_self.copyWith(
dangerType: null == dangerType ? _self.dangerType : dangerType // ignore: cast_nullable_to_non_nullable
as String,iataId: null == iataId ? _self.iataId : iataId // ignore: cast_nullable_to_non_nullable
as String,properShippingName: null == properShippingName ? _self.properShippingName : properShippingName // ignore: cast_nullable_to_non_nullable
as String,maxWeightPAX: null == maxWeightPAX ? _self.maxWeightPAX : maxWeightPAX // ignore: cast_nullable_to_non_nullable
as double,maxWeightCargo: null == maxWeightCargo ? _self.maxWeightCargo : maxWeightCargo // ignore: cast_nullable_to_non_nullable
as double,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PackingDangerousGood].
extension PackingDangerousGoodPatterns on PackingDangerousGood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackingDangerousGood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackingDangerousGood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackingDangerousGood value)  $default,){
final _that = this;
switch (_that) {
case _PackingDangerousGood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackingDangerousGood value)?  $default,){
final _that = this;
switch (_that) {
case _PackingDangerousGood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dangerType,  String iataId,  String properShippingName,  double maxWeightPAX,  double maxWeightCargo,  String remarks,  String imagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackingDangerousGood() when $default != null:
return $default(_that.dangerType,_that.iataId,_that.properShippingName,_that.maxWeightPAX,_that.maxWeightCargo,_that.remarks,_that.imagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dangerType,  String iataId,  String properShippingName,  double maxWeightPAX,  double maxWeightCargo,  String remarks,  String imagePath)  $default,) {final _that = this;
switch (_that) {
case _PackingDangerousGood():
return $default(_that.dangerType,_that.iataId,_that.properShippingName,_that.maxWeightPAX,_that.maxWeightCargo,_that.remarks,_that.imagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dangerType,  String iataId,  String properShippingName,  double maxWeightPAX,  double maxWeightCargo,  String remarks,  String imagePath)?  $default,) {final _that = this;
switch (_that) {
case _PackingDangerousGood() when $default != null:
return $default(_that.dangerType,_that.iataId,_that.properShippingName,_that.maxWeightPAX,_that.maxWeightCargo,_that.remarks,_that.imagePath);case _:
  return null;

}
}

}

/// @nodoc


class _PackingDangerousGood implements PackingDangerousGood {
  const _PackingDangerousGood({required this.dangerType, required this.iataId, required this.properShippingName, required this.maxWeightPAX, required this.maxWeightCargo, required this.remarks, required this.imagePath});
  

@override final  String dangerType;
@override final  String iataId;
@override final  String properShippingName;
@override final  double maxWeightPAX;
@override final  double maxWeightCargo;
@override final  String remarks;
@override final  String imagePath;

/// Create a copy of PackingDangerousGood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackingDangerousGoodCopyWith<_PackingDangerousGood> get copyWith => __$PackingDangerousGoodCopyWithImpl<_PackingDangerousGood>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackingDangerousGood&&(identical(other.dangerType, dangerType) || other.dangerType == dangerType)&&(identical(other.iataId, iataId) || other.iataId == iataId)&&(identical(other.properShippingName, properShippingName) || other.properShippingName == properShippingName)&&(identical(other.maxWeightPAX, maxWeightPAX) || other.maxWeightPAX == maxWeightPAX)&&(identical(other.maxWeightCargo, maxWeightCargo) || other.maxWeightCargo == maxWeightCargo)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}


@override
int get hashCode => Object.hash(runtimeType,dangerType,iataId,properShippingName,maxWeightPAX,maxWeightCargo,remarks,imagePath);

@override
String toString() {
  return 'PackingDangerousGood(dangerType: $dangerType, iataId: $iataId, properShippingName: $properShippingName, maxWeightPAX: $maxWeightPAX, maxWeightCargo: $maxWeightCargo, remarks: $remarks, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$PackingDangerousGoodCopyWith<$Res> implements $PackingDangerousGoodCopyWith<$Res> {
  factory _$PackingDangerousGoodCopyWith(_PackingDangerousGood value, $Res Function(_PackingDangerousGood) _then) = __$PackingDangerousGoodCopyWithImpl;
@override @useResult
$Res call({
 String dangerType, String iataId, String properShippingName, double maxWeightPAX, double maxWeightCargo, String remarks, String imagePath
});




}
/// @nodoc
class __$PackingDangerousGoodCopyWithImpl<$Res>
    implements _$PackingDangerousGoodCopyWith<$Res> {
  __$PackingDangerousGoodCopyWithImpl(this._self, this._then);

  final _PackingDangerousGood _self;
  final $Res Function(_PackingDangerousGood) _then;

/// Create a copy of PackingDangerousGood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dangerType = null,Object? iataId = null,Object? properShippingName = null,Object? maxWeightPAX = null,Object? maxWeightCargo = null,Object? remarks = null,Object? imagePath = null,}) {
  return _then(_PackingDangerousGood(
dangerType: null == dangerType ? _self.dangerType : dangerType // ignore: cast_nullable_to_non_nullable
as String,iataId: null == iataId ? _self.iataId : iataId // ignore: cast_nullable_to_non_nullable
as String,properShippingName: null == properShippingName ? _self.properShippingName : properShippingName // ignore: cast_nullable_to_non_nullable
as String,maxWeightPAX: null == maxWeightPAX ? _self.maxWeightPAX : maxWeightPAX // ignore: cast_nullable_to_non_nullable
as double,maxWeightCargo: null == maxWeightCargo ? _self.maxWeightCargo : maxWeightCargo // ignore: cast_nullable_to_non_nullable
as double,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
