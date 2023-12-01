// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

FirebaseDocument _$FirebaseDocumentFromJson(Map<String, dynamic> json) {
  return _FirebaseDocument.fromJson(json);
}

/// @nodoc
mixin _$FirebaseDocument {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FirebaseDocumentCopyWith<FirebaseDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseDocumentCopyWith<$Res> {
  factory $FirebaseDocumentCopyWith(
          FirebaseDocument value, $Res Function(FirebaseDocument) then) =
      _$FirebaseDocumentCopyWithImpl<$Res, FirebaseDocument>;
  @useResult
  $Res call({String id, String url, String name});
}

/// @nodoc
class _$FirebaseDocumentCopyWithImpl<$Res, $Val extends FirebaseDocument>
    implements $FirebaseDocumentCopyWith<$Res> {
  _$FirebaseDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseDocumentImplCopyWith<$Res>
    implements $FirebaseDocumentCopyWith<$Res> {
  factory _$$FirebaseDocumentImplCopyWith(_$FirebaseDocumentImpl value,
          $Res Function(_$FirebaseDocumentImpl) then) =
      __$$FirebaseDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String url, String name});
}

/// @nodoc
class __$$FirebaseDocumentImplCopyWithImpl<$Res>
    extends _$FirebaseDocumentCopyWithImpl<$Res, _$FirebaseDocumentImpl>
    implements _$$FirebaseDocumentImplCopyWith<$Res> {
  __$$FirebaseDocumentImplCopyWithImpl(_$FirebaseDocumentImpl _value,
      $Res Function(_$FirebaseDocumentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? name = null,
  }) {
    return _then(_$FirebaseDocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
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
class _$FirebaseDocumentImpl implements _FirebaseDocument {
  const _$FirebaseDocumentImpl(
      {required this.id, required this.url, required this.name});

  factory _$FirebaseDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String name;

  @override
  String toString() {
    return 'FirebaseDocument(id: $id, url: $url, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseDocumentImplCopyWith<_$FirebaseDocumentImpl> get copyWith =>
      __$$FirebaseDocumentImplCopyWithImpl<_$FirebaseDocumentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseDocumentImplToJson(
      this,
    );
  }
}

abstract class _FirebaseDocument implements FirebaseDocument {
  const factory _FirebaseDocument(
      {required final String id,
      required final String url,
      required final String name}) = _$FirebaseDocumentImpl;

  factory _FirebaseDocument.fromJson(Map<String, dynamic> json) =
      _$FirebaseDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$FirebaseDocumentImplCopyWith<_$FirebaseDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
