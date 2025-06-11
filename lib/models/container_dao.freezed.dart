// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_dao.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerDao {

 String get id; int get number; String get name; String? get description; String? get typeId; SequentialBuild get sequentialBuild; String? get moduleDestinationId; String? get currentLocationId; bool get isReady; bool get toDeploy;
/// Create a copy of ContainerDao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerDaoCopyWith<ContainerDao> get copyWith => _$ContainerDaoCopyWithImpl<ContainerDao>(this as ContainerDao, _$identity);

  /// Serializes this ContainerDao to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerDao&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.typeId, typeId) || other.typeId == typeId)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild)&&(identical(other.moduleDestinationId, moduleDestinationId) || other.moduleDestinationId == moduleDestinationId)&&(identical(other.currentLocationId, currentLocationId) || other.currentLocationId == currentLocationId)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.toDeploy, toDeploy) || other.toDeploy == toDeploy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,name,description,typeId,sequentialBuild,moduleDestinationId,currentLocationId,isReady,toDeploy);

@override
String toString() {
  return 'ContainerDao(id: $id, number: $number, name: $name, description: $description, typeId: $typeId, sequentialBuild: $sequentialBuild, moduleDestinationId: $moduleDestinationId, currentLocationId: $currentLocationId, isReady: $isReady, toDeploy: $toDeploy)';
}


}

/// @nodoc
abstract mixin class $ContainerDaoCopyWith<$Res>  {
  factory $ContainerDaoCopyWith(ContainerDao value, $Res Function(ContainerDao) _then) = _$ContainerDaoCopyWithImpl;
@useResult
$Res call({
 String id, int number, String name, String? description, String? typeId, SequentialBuild sequentialBuild, String? moduleDestinationId, String? currentLocationId, bool isReady, bool toDeploy
});




}
/// @nodoc
class _$ContainerDaoCopyWithImpl<$Res>
    implements $ContainerDaoCopyWith<$Res> {
  _$ContainerDaoCopyWithImpl(this._self, this._then);

  final ContainerDao _self;
  final $Res Function(ContainerDao) _then;

/// Create a copy of ContainerDao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? name = null,Object? description = freezed,Object? typeId = freezed,Object? sequentialBuild = null,Object? moduleDestinationId = freezed,Object? currentLocationId = freezed,Object? isReady = null,Object? toDeploy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,typeId: freezed == typeId ? _self.typeId : typeId // ignore: cast_nullable_to_non_nullable
as String?,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,moduleDestinationId: freezed == moduleDestinationId ? _self.moduleDestinationId : moduleDestinationId // ignore: cast_nullable_to_non_nullable
as String?,currentLocationId: freezed == currentLocationId ? _self.currentLocationId : currentLocationId // ignore: cast_nullable_to_non_nullable
as String?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,toDeploy: null == toDeploy ? _self.toDeploy : toDeploy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ContainerDao implements ContainerDao {
  const _ContainerDao({required this.id, required this.number, required this.name, this.description, this.typeId, required this.sequentialBuild, this.moduleDestinationId, this.currentLocationId, required this.isReady, required this.toDeploy});
  factory _ContainerDao.fromJson(Map<String, dynamic> json) => _$ContainerDaoFromJson(json);

@override final  String id;
@override final  int number;
@override final  String name;
@override final  String? description;
@override final  String? typeId;
@override final  SequentialBuild sequentialBuild;
@override final  String? moduleDestinationId;
@override final  String? currentLocationId;
@override final  bool isReady;
@override final  bool toDeploy;

/// Create a copy of ContainerDao
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerDaoCopyWith<_ContainerDao> get copyWith => __$ContainerDaoCopyWithImpl<_ContainerDao>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerDaoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerDao&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.typeId, typeId) || other.typeId == typeId)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild)&&(identical(other.moduleDestinationId, moduleDestinationId) || other.moduleDestinationId == moduleDestinationId)&&(identical(other.currentLocationId, currentLocationId) || other.currentLocationId == currentLocationId)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.toDeploy, toDeploy) || other.toDeploy == toDeploy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,name,description,typeId,sequentialBuild,moduleDestinationId,currentLocationId,isReady,toDeploy);

@override
String toString() {
  return 'ContainerDao(id: $id, number: $number, name: $name, description: $description, typeId: $typeId, sequentialBuild: $sequentialBuild, moduleDestinationId: $moduleDestinationId, currentLocationId: $currentLocationId, isReady: $isReady, toDeploy: $toDeploy)';
}


}

/// @nodoc
abstract mixin class _$ContainerDaoCopyWith<$Res> implements $ContainerDaoCopyWith<$Res> {
  factory _$ContainerDaoCopyWith(_ContainerDao value, $Res Function(_ContainerDao) _then) = __$ContainerDaoCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String name, String? description, String? typeId, SequentialBuild sequentialBuild, String? moduleDestinationId, String? currentLocationId, bool isReady, bool toDeploy
});




}
/// @nodoc
class __$ContainerDaoCopyWithImpl<$Res>
    implements _$ContainerDaoCopyWith<$Res> {
  __$ContainerDaoCopyWithImpl(this._self, this._then);

  final _ContainerDao _self;
  final $Res Function(_ContainerDao) _then;

/// Create a copy of ContainerDao
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? name = null,Object? description = freezed,Object? typeId = freezed,Object? sequentialBuild = null,Object? moduleDestinationId = freezed,Object? currentLocationId = freezed,Object? isReady = null,Object? toDeploy = null,}) {
  return _then(_ContainerDao(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,typeId: freezed == typeId ? _self.typeId : typeId // ignore: cast_nullable_to_non_nullable
as String?,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,moduleDestinationId: freezed == moduleDestinationId ? _self.moduleDestinationId : moduleDestinationId // ignore: cast_nullable_to_non_nullable
as String?,currentLocationId: freezed == currentLocationId ? _self.currentLocationId : currentLocationId // ignore: cast_nullable_to_non_nullable
as String?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,toDeploy: null == toDeploy ? _self.toDeploy : toDeploy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
