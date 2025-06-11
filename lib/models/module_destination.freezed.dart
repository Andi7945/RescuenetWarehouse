// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModuleDestination {

 String get id; String get name;
/// Create a copy of ModuleDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleDestinationCopyWith<ModuleDestination> get copyWith => _$ModuleDestinationCopyWithImpl<ModuleDestination>(this as ModuleDestination, _$identity);

  /// Serializes this ModuleDestination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleDestination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ModuleDestination(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ModuleDestinationCopyWith<$Res>  {
  factory $ModuleDestinationCopyWith(ModuleDestination value, $Res Function(ModuleDestination) _then) = _$ModuleDestinationCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$ModuleDestinationCopyWithImpl<$Res>
    implements $ModuleDestinationCopyWith<$Res> {
  _$ModuleDestinationCopyWithImpl(this._self, this._then);

  final ModuleDestination _self;
  final $Res Function(ModuleDestination) _then;

/// Create a copy of ModuleDestination
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

class _ModuleDestination implements ModuleDestination {
  const _ModuleDestination({required this.id, required this.name});
  factory _ModuleDestination.fromJson(Map<String, dynamic> json) => _$ModuleDestinationFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of ModuleDestination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModuleDestinationCopyWith<_ModuleDestination> get copyWith => __$ModuleDestinationCopyWithImpl<_ModuleDestination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModuleDestinationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleDestination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ModuleDestination(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ModuleDestinationCopyWith<$Res> implements $ModuleDestinationCopyWith<$Res> {
  factory _$ModuleDestinationCopyWith(_ModuleDestination value, $Res Function(_ModuleDestination) _then) = __$ModuleDestinationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$ModuleDestinationCopyWithImpl<$Res>
    implements _$ModuleDestinationCopyWith<$Res> {
  __$ModuleDestinationCopyWithImpl(this._self, this._then);

  final _ModuleDestination _self;
  final $Res Function(_ModuleDestination) _then;

/// Create a copy of ModuleDestination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ModuleDestination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
