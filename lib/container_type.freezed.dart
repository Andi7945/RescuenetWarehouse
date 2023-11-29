// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ContainerType _$ContainerTypeFromJson(Map<String, dynamic> json) {
  return _ContainerType.fromJson(json);
}

/// @nodoc
mixin _$ContainerType {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  double get emptyWeight => throw _privateConstructorUsedError;
  String get measurements => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContainerTypeCopyWith<ContainerType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerTypeCopyWith<$Res> {
  factory $ContainerTypeCopyWith(
          ContainerType value, $Res Function(ContainerType) then) =
      _$ContainerTypeCopyWithImpl<$Res, ContainerType>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? imagePath,
      double emptyWeight,
      String measurements});
}

/// @nodoc
class _$ContainerTypeCopyWithImpl<$Res, $Val extends ContainerType>
    implements $ContainerTypeCopyWith<$Res> {
  _$ContainerTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imagePath = freezed,
    Object? emptyWeight = null,
    Object? measurements = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      emptyWeight: null == emptyWeight
          ? _value.emptyWeight
          : emptyWeight // ignore: cast_nullable_to_non_nullable
              as double,
      measurements: null == measurements
          ? _value.measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContainerTypeImplCopyWith<$Res>
    implements $ContainerTypeCopyWith<$Res> {
  factory _$$ContainerTypeImplCopyWith(
          _$ContainerTypeImpl value, $Res Function(_$ContainerTypeImpl) then) =
      __$$ContainerTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? imagePath,
      double emptyWeight,
      String measurements});
}

/// @nodoc
class __$$ContainerTypeImplCopyWithImpl<$Res>
    extends _$ContainerTypeCopyWithImpl<$Res, _$ContainerTypeImpl>
    implements _$$ContainerTypeImplCopyWith<$Res> {
  __$$ContainerTypeImplCopyWithImpl(
      _$ContainerTypeImpl _value, $Res Function(_$ContainerTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imagePath = freezed,
    Object? emptyWeight = null,
    Object? measurements = null,
  }) {
    return _then(_$ContainerTypeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      emptyWeight: null == emptyWeight
          ? _value.emptyWeight
          : emptyWeight // ignore: cast_nullable_to_non_nullable
              as double,
      measurements: null == measurements
          ? _value.measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContainerTypeImpl
    with DiagnosticableTreeMixin
    implements _ContainerType {
  const _$ContainerTypeImpl(
      {required this.id,
      required this.name,
      this.imagePath,
      required this.emptyWeight,
      required this.measurements});

  factory _$ContainerTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContainerTypeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? imagePath;
  @override
  final double emptyWeight;
  @override
  final String measurements;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ContainerType(id: $id, name: $name, imagePath: $imagePath, emptyWeight: $emptyWeight, measurements: $measurements)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ContainerType'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('imagePath', imagePath))
      ..add(DiagnosticsProperty('emptyWeight', emptyWeight))
      ..add(DiagnosticsProperty('measurements', measurements));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.emptyWeight, emptyWeight) ||
                other.emptyWeight == emptyWeight) &&
            (identical(other.measurements, measurements) ||
                other.measurements == measurements));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, imagePath, emptyWeight, measurements);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerTypeImplCopyWith<_$ContainerTypeImpl> get copyWith =>
      __$$ContainerTypeImplCopyWithImpl<_$ContainerTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContainerTypeImplToJson(
      this,
    );
  }
}

abstract class _ContainerType implements ContainerType {
  const factory _ContainerType(
      {required final String id,
      required final String name,
      final String? imagePath,
      required final double emptyWeight,
      required final String measurements}) = _$ContainerTypeImpl;

  factory _ContainerType.fromJson(Map<String, dynamic> json) =
      _$ContainerTypeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get imagePath;
  @override
  double get emptyWeight;
  @override
  String get measurements;
  @override
  @JsonKey(ignore: true)
  _$$ContainerTypeImplCopyWith<_$ContainerTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
