// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentLocation {

 String get id; String get name;
/// Create a copy of CurrentLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentLocationCopyWith<CurrentLocation> get copyWith => _$CurrentLocationCopyWithImpl<CurrentLocation>(this as CurrentLocation, _$identity);

  /// Serializes this CurrentLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CurrentLocation(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CurrentLocationCopyWith<$Res>  {
  factory $CurrentLocationCopyWith(CurrentLocation value, $Res Function(CurrentLocation) _then) = _$CurrentLocationCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$CurrentLocationCopyWithImpl<$Res>
    implements $CurrentLocationCopyWith<$Res> {
  _$CurrentLocationCopyWithImpl(this._self, this._then);

  final CurrentLocation _self;
  final $Res Function(CurrentLocation) _then;

/// Create a copy of CurrentLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CurrentLocation implements CurrentLocation {
  const _CurrentLocation({required this.id, required this.name});
  factory _CurrentLocation.fromJson(Map<String, dynamic> json) => _$CurrentLocationFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of CurrentLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentLocationCopyWith<_CurrentLocation> get copyWith => __$CurrentLocationCopyWithImpl<_CurrentLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CurrentLocation(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CurrentLocationCopyWith<$Res> implements $CurrentLocationCopyWith<$Res> {
  factory _$CurrentLocationCopyWith(_CurrentLocation value, $Res Function(_CurrentLocation) _then) = __$CurrentLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$CurrentLocationCopyWithImpl<$Res>
    implements _$CurrentLocationCopyWith<$Res> {
  __$CurrentLocationCopyWithImpl(this._self, this._then);

  final _CurrentLocation _self;
  final $Res Function(_CurrentLocation) _then;

/// Create a copy of CurrentLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CurrentLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
