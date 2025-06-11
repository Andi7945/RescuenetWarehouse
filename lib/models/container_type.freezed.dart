// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerType implements DiagnosticableTreeMixin {

 String get id; String get name; String? get imagePath; double get emptyWeight; String get measurements;
/// Create a copy of ContainerType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerTypeCopyWith<ContainerType> get copyWith => _$ContainerTypeCopyWithImpl<ContainerType>(this as ContainerType, _$identity);

  /// Serializes this ContainerType to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ContainerType'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('imagePath', imagePath))..add(DiagnosticsProperty('emptyWeight', emptyWeight))..add(DiagnosticsProperty('measurements', measurements));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerType&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.emptyWeight, emptyWeight) || other.emptyWeight == emptyWeight)&&(identical(other.measurements, measurements) || other.measurements == measurements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,imagePath,emptyWeight,measurements);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ContainerType(id: $id, name: $name, imagePath: $imagePath, emptyWeight: $emptyWeight, measurements: $measurements)';
}


}

/// @nodoc
abstract mixin class $ContainerTypeCopyWith<$Res>  {
  factory $ContainerTypeCopyWith(ContainerType value, $Res Function(ContainerType) _then) = _$ContainerTypeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? imagePath, double emptyWeight, String measurements
});




}
/// @nodoc
class _$ContainerTypeCopyWithImpl<$Res>
    implements $ContainerTypeCopyWith<$Res> {
  _$ContainerTypeCopyWithImpl(this._self, this._then);

  final ContainerType _self;
  final $Res Function(ContainerType) _then;

/// Create a copy of ContainerType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? imagePath = freezed,Object? emptyWeight = null,Object? measurements = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,emptyWeight: null == emptyWeight ? _self.emptyWeight : emptyWeight // ignore: cast_nullable_to_non_nullable
as double,measurements: null == measurements ? _self.measurements : measurements // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ContainerType with DiagnosticableTreeMixin implements ContainerType {
  const _ContainerType({required this.id, required this.name, this.imagePath, required this.emptyWeight, required this.measurements});
  factory _ContainerType.fromJson(Map<String, dynamic> json) => _$ContainerTypeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? imagePath;
@override final  double emptyWeight;
@override final  String measurements;

/// Create a copy of ContainerType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerTypeCopyWith<_ContainerType> get copyWith => __$ContainerTypeCopyWithImpl<_ContainerType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerTypeToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ContainerType'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('imagePath', imagePath))..add(DiagnosticsProperty('emptyWeight', emptyWeight))..add(DiagnosticsProperty('measurements', measurements));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerType&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.emptyWeight, emptyWeight) || other.emptyWeight == emptyWeight)&&(identical(other.measurements, measurements) || other.measurements == measurements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,imagePath,emptyWeight,measurements);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ContainerType(id: $id, name: $name, imagePath: $imagePath, emptyWeight: $emptyWeight, measurements: $measurements)';
}


}

/// @nodoc
abstract mixin class _$ContainerTypeCopyWith<$Res> implements $ContainerTypeCopyWith<$Res> {
  factory _$ContainerTypeCopyWith(_ContainerType value, $Res Function(_ContainerType) _then) = __$ContainerTypeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? imagePath, double emptyWeight, String measurements
});




}
/// @nodoc
class __$ContainerTypeCopyWithImpl<$Res>
    implements _$ContainerTypeCopyWith<$Res> {
  __$ContainerTypeCopyWithImpl(this._self, this._then);

  final _ContainerType _self;
  final $Res Function(_ContainerType) _then;

/// Create a copy of ContainerType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? imagePath = freezed,Object? emptyWeight = null,Object? measurements = null,}) {
  return _then(_ContainerType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,emptyWeight: null == emptyWeight ? _self.emptyWeight : emptyWeight // ignore: cast_nullable_to_non_nullable
as double,measurements: null == measurements ? _self.measurements : measurements // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
