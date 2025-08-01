// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rescue_container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RescueContainer {

 String get id; int get number; String get name; String? get description; ContainerType? get type; SequentialBuild get sequentialBuild; ModuleDestination? get moduleDestination; CurrentLocation? get currentLocation; bool get isReady; bool get toDeploy;
/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RescueContainerCopyWith<RescueContainer> get copyWith => _$RescueContainerCopyWithImpl<RescueContainer>(this as RescueContainer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RescueContainer&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild)&&(identical(other.moduleDestination, moduleDestination) || other.moduleDestination == moduleDestination)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.toDeploy, toDeploy) || other.toDeploy == toDeploy));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,name,description,type,sequentialBuild,moduleDestination,currentLocation,isReady,toDeploy);

@override
String toString() {
  return 'RescueContainer(id: $id, number: $number, name: $name, description: $description, type: $type, sequentialBuild: $sequentialBuild, moduleDestination: $moduleDestination, currentLocation: $currentLocation, isReady: $isReady, toDeploy: $toDeploy)';
}


}

/// @nodoc
abstract mixin class $RescueContainerCopyWith<$Res>  {
  factory $RescueContainerCopyWith(RescueContainer value, $Res Function(RescueContainer) _then) = _$RescueContainerCopyWithImpl;
@useResult
$Res call({
 String id, int number, String name, String? description, ContainerType? type, SequentialBuild sequentialBuild, ModuleDestination? moduleDestination, CurrentLocation? currentLocation, bool isReady, bool toDeploy
});


$ContainerTypeCopyWith<$Res>? get type;$ModuleDestinationCopyWith<$Res>? get moduleDestination;$CurrentLocationCopyWith<$Res>? get currentLocation;

}
/// @nodoc
class _$RescueContainerCopyWithImpl<$Res>
    implements $RescueContainerCopyWith<$Res> {
  _$RescueContainerCopyWithImpl(this._self, this._then);

  final RescueContainer _self;
  final $Res Function(RescueContainer) _then;

/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? name = null,Object? description = freezed,Object? type = freezed,Object? sequentialBuild = null,Object? moduleDestination = freezed,Object? currentLocation = freezed,Object? isReady = null,Object? toDeploy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContainerType?,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,moduleDestination: freezed == moduleDestination ? _self.moduleDestination : moduleDestination // ignore: cast_nullable_to_non_nullable
as ModuleDestination?,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as CurrentLocation?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,toDeploy: null == toDeploy ? _self.toDeploy : toDeploy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerTypeCopyWith<$Res>? get type {
    if (_self.type == null) {
    return null;
  }

  return $ContainerTypeCopyWith<$Res>(_self.type!, (value) {
    return _then(_self.copyWith(type: value));
  });
}/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModuleDestinationCopyWith<$Res>? get moduleDestination {
    if (_self.moduleDestination == null) {
    return null;
  }

  return $ModuleDestinationCopyWith<$Res>(_self.moduleDestination!, (value) {
    return _then(_self.copyWith(moduleDestination: value));
  });
}/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentLocationCopyWith<$Res>? get currentLocation {
    if (_self.currentLocation == null) {
    return null;
  }

  return $CurrentLocationCopyWith<$Res>(_self.currentLocation!, (value) {
    return _then(_self.copyWith(currentLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RescueContainer].
extension RescueContainerPatterns on RescueContainer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RescueContainer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RescueContainer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RescueContainer value)  $default,){
final _that = this;
switch (_that) {
case _RescueContainer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RescueContainer value)?  $default,){
final _that = this;
switch (_that) {
case _RescueContainer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String name,  String? description,  ContainerType? type,  SequentialBuild sequentialBuild,  ModuleDestination? moduleDestination,  CurrentLocation? currentLocation,  bool isReady,  bool toDeploy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RescueContainer() when $default != null:
return $default(_that.id,_that.number,_that.name,_that.description,_that.type,_that.sequentialBuild,_that.moduleDestination,_that.currentLocation,_that.isReady,_that.toDeploy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String name,  String? description,  ContainerType? type,  SequentialBuild sequentialBuild,  ModuleDestination? moduleDestination,  CurrentLocation? currentLocation,  bool isReady,  bool toDeploy)  $default,) {final _that = this;
switch (_that) {
case _RescueContainer():
return $default(_that.id,_that.number,_that.name,_that.description,_that.type,_that.sequentialBuild,_that.moduleDestination,_that.currentLocation,_that.isReady,_that.toDeploy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String name,  String? description,  ContainerType? type,  SequentialBuild sequentialBuild,  ModuleDestination? moduleDestination,  CurrentLocation? currentLocation,  bool isReady,  bool toDeploy)?  $default,) {final _that = this;
switch (_that) {
case _RescueContainer() when $default != null:
return $default(_that.id,_that.number,_that.name,_that.description,_that.type,_that.sequentialBuild,_that.moduleDestination,_that.currentLocation,_that.isReady,_that.toDeploy);case _:
  return null;

}
}

}

/// @nodoc


class _RescueContainer extends RescueContainer {
  const _RescueContainer({required this.id, required this.number, required this.name, this.description, this.type, required this.sequentialBuild, this.moduleDestination, this.currentLocation, required this.isReady, required this.toDeploy}): super._();
  

@override final  String id;
@override final  int number;
@override final  String name;
@override final  String? description;
@override final  ContainerType? type;
@override final  SequentialBuild sequentialBuild;
@override final  ModuleDestination? moduleDestination;
@override final  CurrentLocation? currentLocation;
@override final  bool isReady;
@override final  bool toDeploy;

/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RescueContainerCopyWith<_RescueContainer> get copyWith => __$RescueContainerCopyWithImpl<_RescueContainer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RescueContainer&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild)&&(identical(other.moduleDestination, moduleDestination) || other.moduleDestination == moduleDestination)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.toDeploy, toDeploy) || other.toDeploy == toDeploy));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,name,description,type,sequentialBuild,moduleDestination,currentLocation,isReady,toDeploy);

@override
String toString() {
  return 'RescueContainer(id: $id, number: $number, name: $name, description: $description, type: $type, sequentialBuild: $sequentialBuild, moduleDestination: $moduleDestination, currentLocation: $currentLocation, isReady: $isReady, toDeploy: $toDeploy)';
}


}

/// @nodoc
abstract mixin class _$RescueContainerCopyWith<$Res> implements $RescueContainerCopyWith<$Res> {
  factory _$RescueContainerCopyWith(_RescueContainer value, $Res Function(_RescueContainer) _then) = __$RescueContainerCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String name, String? description, ContainerType? type, SequentialBuild sequentialBuild, ModuleDestination? moduleDestination, CurrentLocation? currentLocation, bool isReady, bool toDeploy
});


@override $ContainerTypeCopyWith<$Res>? get type;@override $ModuleDestinationCopyWith<$Res>? get moduleDestination;@override $CurrentLocationCopyWith<$Res>? get currentLocation;

}
/// @nodoc
class __$RescueContainerCopyWithImpl<$Res>
    implements _$RescueContainerCopyWith<$Res> {
  __$RescueContainerCopyWithImpl(this._self, this._then);

  final _RescueContainer _self;
  final $Res Function(_RescueContainer) _then;

/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? name = null,Object? description = freezed,Object? type = freezed,Object? sequentialBuild = null,Object? moduleDestination = freezed,Object? currentLocation = freezed,Object? isReady = null,Object? toDeploy = null,}) {
  return _then(_RescueContainer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContainerType?,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,moduleDestination: freezed == moduleDestination ? _self.moduleDestination : moduleDestination // ignore: cast_nullable_to_non_nullable
as ModuleDestination?,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as CurrentLocation?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,toDeploy: null == toDeploy ? _self.toDeploy : toDeploy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerTypeCopyWith<$Res>? get type {
    if (_self.type == null) {
    return null;
  }

  return $ContainerTypeCopyWith<$Res>(_self.type!, (value) {
    return _then(_self.copyWith(type: value));
  });
}/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModuleDestinationCopyWith<$Res>? get moduleDestination {
    if (_self.moduleDestination == null) {
    return null;
  }

  return $ModuleDestinationCopyWith<$Res>(_self.moduleDestination!, (value) {
    return _then(_self.copyWith(moduleDestination: value));
  });
}/// Create a copy of RescueContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentLocationCopyWith<$Res>? get currentLocation {
    if (_self.currentLocation == null) {
    return null;
  }

  return $CurrentLocationCopyWith<$Res>(_self.currentLocation!, (value) {
    return _then(_self.copyWith(currentLocation: value));
  });
}
}

// dart format on
