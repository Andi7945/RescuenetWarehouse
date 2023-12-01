// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ModuleDestination _$ModuleDestinationFromJson(Map<String, dynamic> json) {
  return _ModuleDestination.fromJson(json);
}

/// @nodoc
mixin _$ModuleDestination {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleDestinationCopyWith<ModuleDestination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleDestinationCopyWith<$Res> {
  factory $ModuleDestinationCopyWith(
          ModuleDestination value, $Res Function(ModuleDestination) then) =
      _$ModuleDestinationCopyWithImpl<$Res, ModuleDestination>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$ModuleDestinationCopyWithImpl<$Res, $Val extends ModuleDestination>
    implements $ModuleDestinationCopyWith<$Res> {
  _$ModuleDestinationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleDestinationImplCopyWith<$Res>
    implements $ModuleDestinationCopyWith<$Res> {
  factory _$$ModuleDestinationImplCopyWith(_$ModuleDestinationImpl value,
          $Res Function(_$ModuleDestinationImpl) then) =
      __$$ModuleDestinationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$ModuleDestinationImplCopyWithImpl<$Res>
    extends _$ModuleDestinationCopyWithImpl<$Res, _$ModuleDestinationImpl>
    implements _$$ModuleDestinationImplCopyWith<$Res> {
  __$$ModuleDestinationImplCopyWithImpl(_$ModuleDestinationImpl _value,
      $Res Function(_$ModuleDestinationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$ModuleDestinationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleDestinationImpl implements _ModuleDestination {
  const _$ModuleDestinationImpl({required this.id, required this.name});

  factory _$ModuleDestinationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleDestinationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'ModuleDestination(id: $id, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleDestinationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleDestinationImplCopyWith<_$ModuleDestinationImpl> get copyWith =>
      __$$ModuleDestinationImplCopyWithImpl<_$ModuleDestinationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleDestinationImplToJson(
      this,
    );
  }
}

abstract class _ModuleDestination implements ModuleDestination {
  const factory _ModuleDestination(
      {required final String id,
      required final String name}) = _$ModuleDestinationImpl;

  factory _ModuleDestination.fromJson(Map<String, dynamic> json) =
      _$ModuleDestinationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$ModuleDestinationImplCopyWith<_$ModuleDestinationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
