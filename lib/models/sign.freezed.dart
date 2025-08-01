// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Sign {

 String get id; String? get unNumber; String? get imagePath; String? get instructions; String? get remarks; List<FirebaseDocument> get sdsPath; String? get dangerType; String? get properShippingName; double get maxWeightPAX; double get maxWeightCargo; List<FirebaseDocument> get otherDocuments;
/// Create a copy of Sign
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignCopyWith<Sign> get copyWith => _$SignCopyWithImpl<Sign>(this as Sign, _$identity);

  /// Serializes this Sign to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sign&&(identical(other.id, id) || other.id == id)&&(identical(other.unNumber, unNumber) || other.unNumber == unNumber)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&const DeepCollectionEquality().equals(other.sdsPath, sdsPath)&&(identical(other.dangerType, dangerType) || other.dangerType == dangerType)&&(identical(other.properShippingName, properShippingName) || other.properShippingName == properShippingName)&&(identical(other.maxWeightPAX, maxWeightPAX) || other.maxWeightPAX == maxWeightPAX)&&(identical(other.maxWeightCargo, maxWeightCargo) || other.maxWeightCargo == maxWeightCargo)&&const DeepCollectionEquality().equals(other.otherDocuments, otherDocuments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unNumber,imagePath,instructions,remarks,const DeepCollectionEquality().hash(sdsPath),dangerType,properShippingName,maxWeightPAX,maxWeightCargo,const DeepCollectionEquality().hash(otherDocuments));

@override
String toString() {
  return 'Sign(id: $id, unNumber: $unNumber, imagePath: $imagePath, instructions: $instructions, remarks: $remarks, sdsPath: $sdsPath, dangerType: $dangerType, properShippingName: $properShippingName, maxWeightPAX: $maxWeightPAX, maxWeightCargo: $maxWeightCargo, otherDocuments: $otherDocuments)';
}


}

/// @nodoc
abstract mixin class $SignCopyWith<$Res>  {
  factory $SignCopyWith(Sign value, $Res Function(Sign) _then) = _$SignCopyWithImpl;
@useResult
$Res call({
 String id, String? unNumber, String? imagePath, String? instructions, String? remarks, List<FirebaseDocument> sdsPath, String? dangerType, String? properShippingName, double maxWeightPAX, double maxWeightCargo, List<FirebaseDocument> otherDocuments
});




}
/// @nodoc
class _$SignCopyWithImpl<$Res>
    implements $SignCopyWith<$Res> {
  _$SignCopyWithImpl(this._self, this._then);

  final Sign _self;
  final $Res Function(Sign) _then;

/// Create a copy of Sign
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unNumber = freezed,Object? imagePath = freezed,Object? instructions = freezed,Object? remarks = freezed,Object? sdsPath = null,Object? dangerType = freezed,Object? properShippingName = freezed,Object? maxWeightPAX = null,Object? maxWeightCargo = null,Object? otherDocuments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unNumber: freezed == unNumber ? _self.unNumber : unNumber // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,sdsPath: null == sdsPath ? _self.sdsPath : sdsPath // ignore: cast_nullable_to_non_nullable
as List<FirebaseDocument>,dangerType: freezed == dangerType ? _self.dangerType : dangerType // ignore: cast_nullable_to_non_nullable
as String?,properShippingName: freezed == properShippingName ? _self.properShippingName : properShippingName // ignore: cast_nullable_to_non_nullable
as String?,maxWeightPAX: null == maxWeightPAX ? _self.maxWeightPAX : maxWeightPAX // ignore: cast_nullable_to_non_nullable
as double,maxWeightCargo: null == maxWeightCargo ? _self.maxWeightCargo : maxWeightCargo // ignore: cast_nullable_to_non_nullable
as double,otherDocuments: null == otherDocuments ? _self.otherDocuments : otherDocuments // ignore: cast_nullable_to_non_nullable
as List<FirebaseDocument>,
  ));
}

}


/// Adds pattern-matching-related methods to [Sign].
extension SignPatterns on Sign {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sign value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sign() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sign value)  $default,){
final _that = this;
switch (_that) {
case _Sign():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sign value)?  $default,){
final _that = this;
switch (_that) {
case _Sign() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? unNumber,  String? imagePath,  String? instructions,  String? remarks,  List<FirebaseDocument> sdsPath,  String? dangerType,  String? properShippingName,  double maxWeightPAX,  double maxWeightCargo,  List<FirebaseDocument> otherDocuments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sign() when $default != null:
return $default(_that.id,_that.unNumber,_that.imagePath,_that.instructions,_that.remarks,_that.sdsPath,_that.dangerType,_that.properShippingName,_that.maxWeightPAX,_that.maxWeightCargo,_that.otherDocuments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? unNumber,  String? imagePath,  String? instructions,  String? remarks,  List<FirebaseDocument> sdsPath,  String? dangerType,  String? properShippingName,  double maxWeightPAX,  double maxWeightCargo,  List<FirebaseDocument> otherDocuments)  $default,) {final _that = this;
switch (_that) {
case _Sign():
return $default(_that.id,_that.unNumber,_that.imagePath,_that.instructions,_that.remarks,_that.sdsPath,_that.dangerType,_that.properShippingName,_that.maxWeightPAX,_that.maxWeightCargo,_that.otherDocuments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? unNumber,  String? imagePath,  String? instructions,  String? remarks,  List<FirebaseDocument> sdsPath,  String? dangerType,  String? properShippingName,  double maxWeightPAX,  double maxWeightCargo,  List<FirebaseDocument> otherDocuments)?  $default,) {final _that = this;
switch (_that) {
case _Sign() when $default != null:
return $default(_that.id,_that.unNumber,_that.imagePath,_that.instructions,_that.remarks,_that.sdsPath,_that.dangerType,_that.properShippingName,_that.maxWeightPAX,_that.maxWeightCargo,_that.otherDocuments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sign implements Sign {
  const _Sign({required this.id, this.unNumber, this.imagePath, this.instructions, this.remarks, final  List<FirebaseDocument> sdsPath = const [], this.dangerType, this.properShippingName, this.maxWeightPAX = 0.0, this.maxWeightCargo = 0.0, final  List<FirebaseDocument> otherDocuments = const []}): _sdsPath = sdsPath,_otherDocuments = otherDocuments;
  factory _Sign.fromJson(Map<String, dynamic> json) => _$SignFromJson(json);

@override final  String id;
@override final  String? unNumber;
@override final  String? imagePath;
@override final  String? instructions;
@override final  String? remarks;
 final  List<FirebaseDocument> _sdsPath;
@override@JsonKey() List<FirebaseDocument> get sdsPath {
  if (_sdsPath is EqualUnmodifiableListView) return _sdsPath;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sdsPath);
}

@override final  String? dangerType;
@override final  String? properShippingName;
@override@JsonKey() final  double maxWeightPAX;
@override@JsonKey() final  double maxWeightCargo;
 final  List<FirebaseDocument> _otherDocuments;
@override@JsonKey() List<FirebaseDocument> get otherDocuments {
  if (_otherDocuments is EqualUnmodifiableListView) return _otherDocuments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_otherDocuments);
}


/// Create a copy of Sign
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignCopyWith<_Sign> get copyWith => __$SignCopyWithImpl<_Sign>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sign&&(identical(other.id, id) || other.id == id)&&(identical(other.unNumber, unNumber) || other.unNumber == unNumber)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&const DeepCollectionEquality().equals(other._sdsPath, _sdsPath)&&(identical(other.dangerType, dangerType) || other.dangerType == dangerType)&&(identical(other.properShippingName, properShippingName) || other.properShippingName == properShippingName)&&(identical(other.maxWeightPAX, maxWeightPAX) || other.maxWeightPAX == maxWeightPAX)&&(identical(other.maxWeightCargo, maxWeightCargo) || other.maxWeightCargo == maxWeightCargo)&&const DeepCollectionEquality().equals(other._otherDocuments, _otherDocuments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unNumber,imagePath,instructions,remarks,const DeepCollectionEquality().hash(_sdsPath),dangerType,properShippingName,maxWeightPAX,maxWeightCargo,const DeepCollectionEquality().hash(_otherDocuments));

@override
String toString() {
  return 'Sign(id: $id, unNumber: $unNumber, imagePath: $imagePath, instructions: $instructions, remarks: $remarks, sdsPath: $sdsPath, dangerType: $dangerType, properShippingName: $properShippingName, maxWeightPAX: $maxWeightPAX, maxWeightCargo: $maxWeightCargo, otherDocuments: $otherDocuments)';
}


}

/// @nodoc
abstract mixin class _$SignCopyWith<$Res> implements $SignCopyWith<$Res> {
  factory _$SignCopyWith(_Sign value, $Res Function(_Sign) _then) = __$SignCopyWithImpl;
@override @useResult
$Res call({
 String id, String? unNumber, String? imagePath, String? instructions, String? remarks, List<FirebaseDocument> sdsPath, String? dangerType, String? properShippingName, double maxWeightPAX, double maxWeightCargo, List<FirebaseDocument> otherDocuments
});




}
/// @nodoc
class __$SignCopyWithImpl<$Res>
    implements _$SignCopyWith<$Res> {
  __$SignCopyWithImpl(this._self, this._then);

  final _Sign _self;
  final $Res Function(_Sign) _then;

/// Create a copy of Sign
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unNumber = freezed,Object? imagePath = freezed,Object? instructions = freezed,Object? remarks = freezed,Object? sdsPath = null,Object? dangerType = freezed,Object? properShippingName = freezed,Object? maxWeightPAX = null,Object? maxWeightCargo = null,Object? otherDocuments = null,}) {
  return _then(_Sign(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unNumber: freezed == unNumber ? _self.unNumber : unNumber // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,sdsPath: null == sdsPath ? _self._sdsPath : sdsPath // ignore: cast_nullable_to_non_nullable
as List<FirebaseDocument>,dangerType: freezed == dangerType ? _self.dangerType : dangerType // ignore: cast_nullable_to_non_nullable
as String?,properShippingName: freezed == properShippingName ? _self.properShippingName : properShippingName // ignore: cast_nullable_to_non_nullable
as String?,maxWeightPAX: null == maxWeightPAX ? _self.maxWeightPAX : maxWeightPAX // ignore: cast_nullable_to_non_nullable
as double,maxWeightCargo: null == maxWeightCargo ? _self.maxWeightCargo : maxWeightCargo // ignore: cast_nullable_to_non_nullable
as double,otherDocuments: null == otherDocuments ? _self._otherDocuments : otherDocuments // ignore: cast_nullable_to_non_nullable
as List<FirebaseDocument>,
  ));
}


}

// dart format on
