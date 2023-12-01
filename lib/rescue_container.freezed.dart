// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rescue_container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$RescueContainer {
  String get id => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  ContainerType? get type => throw _privateConstructorUsedError;
  SequentialBuild get sequentialBuild => throw _privateConstructorUsedError;
  ModuleDestination? get moduleDestination =>
      throw _privateConstructorUsedError;
  CurrentLocation? get currentLocation => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;
  bool get toDeploy => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RescueContainerCopyWith<RescueContainer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RescueContainerCopyWith<$Res> {
  factory $RescueContainerCopyWith(
          RescueContainer value, $Res Function(RescueContainer) then) =
      _$RescueContainerCopyWithImpl<$Res, RescueContainer>;
  @useResult
  $Res call(
      {String id,
      int number,
      String name,
      String? description,
      ContainerType? type,
      SequentialBuild sequentialBuild,
      ModuleDestination? moduleDestination,
      CurrentLocation? currentLocation,
      bool isReady,
      bool toDeploy});

  $ContainerTypeCopyWith<$Res>? get type;
  $ModuleDestinationCopyWith<$Res>? get moduleDestination;
  $CurrentLocationCopyWith<$Res>? get currentLocation;
}

/// @nodoc
class _$RescueContainerCopyWithImpl<$Res, $Val extends RescueContainer>
    implements $RescueContainerCopyWith<$Res> {
  _$RescueContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = freezed,
    Object? sequentialBuild = null,
    Object? moduleDestination = freezed,
    Object? currentLocation = freezed,
    Object? isReady = null,
    Object? toDeploy = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ContainerType?,
      sequentialBuild: null == sequentialBuild
          ? _value.sequentialBuild
          : sequentialBuild // ignore: cast_nullable_to_non_nullable
              as SequentialBuild,
      moduleDestination: freezed == moduleDestination
          ? _value.moduleDestination
          : moduleDestination // ignore: cast_nullable_to_non_nullable
              as ModuleDestination?,
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as CurrentLocation?,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      toDeploy: null == toDeploy
          ? _value.toDeploy
          : toDeploy // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ContainerTypeCopyWith<$Res>? get type {
    if (_value.type == null) {
      return null;
    }

    return $ContainerTypeCopyWith<$Res>(_value.type!, (value) {
      return _then(_value.copyWith(type: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ModuleDestinationCopyWith<$Res>? get moduleDestination {
    if (_value.moduleDestination == null) {
      return null;
    }

    return $ModuleDestinationCopyWith<$Res>(_value.moduleDestination!, (value) {
      return _then(_value.copyWith(moduleDestination: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CurrentLocationCopyWith<$Res>? get currentLocation {
    if (_value.currentLocation == null) {
      return null;
    }

    return $CurrentLocationCopyWith<$Res>(_value.currentLocation!, (value) {
      return _then(_value.copyWith(currentLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RescueContainerImplCopyWith<$Res>
    implements $RescueContainerCopyWith<$Res> {
  factory _$$RescueContainerImplCopyWith(_$RescueContainerImpl value,
          $Res Function(_$RescueContainerImpl) then) =
      __$$RescueContainerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int number,
      String name,
      String? description,
      ContainerType? type,
      SequentialBuild sequentialBuild,
      ModuleDestination? moduleDestination,
      CurrentLocation? currentLocation,
      bool isReady,
      bool toDeploy});

  @override
  $ContainerTypeCopyWith<$Res>? get type;
  @override
  $ModuleDestinationCopyWith<$Res>? get moduleDestination;
  @override
  $CurrentLocationCopyWith<$Res>? get currentLocation;
}

/// @nodoc
class __$$RescueContainerImplCopyWithImpl<$Res>
    extends _$RescueContainerCopyWithImpl<$Res, _$RescueContainerImpl>
    implements _$$RescueContainerImplCopyWith<$Res> {
  __$$RescueContainerImplCopyWithImpl(
      _$RescueContainerImpl _value, $Res Function(_$RescueContainerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = freezed,
    Object? sequentialBuild = null,
    Object? moduleDestination = freezed,
    Object? currentLocation = freezed,
    Object? isReady = null,
    Object? toDeploy = null,
  }) {
    return _then(_$RescueContainerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ContainerType?,
      sequentialBuild: null == sequentialBuild
          ? _value.sequentialBuild
          : sequentialBuild // ignore: cast_nullable_to_non_nullable
              as SequentialBuild,
      moduleDestination: freezed == moduleDestination
          ? _value.moduleDestination
          : moduleDestination // ignore: cast_nullable_to_non_nullable
              as ModuleDestination?,
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as CurrentLocation?,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      toDeploy: null == toDeploy
          ? _value.toDeploy
          : toDeploy // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$RescueContainerImpl extends _RescueContainer {
  const _$RescueContainerImpl(
      {required this.id,
      required this.number,
      required this.name,
      this.description,
      this.type,
      required this.sequentialBuild,
      this.moduleDestination,
      this.currentLocation,
      required this.isReady,
      required this.toDeploy})
      : super._();

  @override
  final String id;
  @override
  final int number;
  @override
  final String name;
  @override
  final String? description;
  @override
  final ContainerType? type;
  @override
  final SequentialBuild sequentialBuild;
  @override
  final ModuleDestination? moduleDestination;
  @override
  final CurrentLocation? currentLocation;
  @override
  final bool isReady;
  @override
  final bool toDeploy;

  @override
  String toString() {
    return 'RescueContainer(id: $id, number: $number, name: $name, description: $description, type: $type, sequentialBuild: $sequentialBuild, moduleDestination: $moduleDestination, currentLocation: $currentLocation, isReady: $isReady, toDeploy: $toDeploy)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RescueContainerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sequentialBuild, sequentialBuild) ||
                other.sequentialBuild == sequentialBuild) &&
            (identical(other.moduleDestination, moduleDestination) ||
                other.moduleDestination == moduleDestination) &&
            (identical(other.currentLocation, currentLocation) ||
                other.currentLocation == currentLocation) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.toDeploy, toDeploy) ||
                other.toDeploy == toDeploy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      number,
      name,
      description,
      type,
      sequentialBuild,
      moduleDestination,
      currentLocation,
      isReady,
      toDeploy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RescueContainerImplCopyWith<_$RescueContainerImpl> get copyWith =>
      __$$RescueContainerImplCopyWithImpl<_$RescueContainerImpl>(
          this, _$identity);
}

abstract class _RescueContainer extends RescueContainer {
  const factory _RescueContainer(
      {required final String id,
      required final int number,
      required final String name,
      final String? description,
      final ContainerType? type,
      required final SequentialBuild sequentialBuild,
      final ModuleDestination? moduleDestination,
      final CurrentLocation? currentLocation,
      required final bool isReady,
      required final bool toDeploy}) = _$RescueContainerImpl;
  const _RescueContainer._() : super._();

  @override
  String get id;
  @override
  int get number;
  @override
  String get name;
  @override
  String? get description;
  @override
  ContainerType? get type;
  @override
  SequentialBuild get sequentialBuild;
  @override
  ModuleDestination? get moduleDestination;
  @override
  CurrentLocation? get currentLocation;
  @override
  bool get isReady;
  @override
  bool get toDeploy;
  @override
  @JsonKey(ignore: true)
  _$$RescueContainerImplCopyWith<_$RescueContainerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
