// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FirebaseDocument {

 String get id; String get url; String get name;
/// Create a copy of FirebaseDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirebaseDocumentCopyWith<FirebaseDocument> get copyWith => _$FirebaseDocumentCopyWithImpl<FirebaseDocument>(this as FirebaseDocument, _$identity);

  /// Serializes this FirebaseDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirebaseDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,name);

@override
String toString() {
  return 'FirebaseDocument(id: $id, url: $url, name: $name)';
}


}

/// @nodoc
abstract mixin class $FirebaseDocumentCopyWith<$Res>  {
  factory $FirebaseDocumentCopyWith(FirebaseDocument value, $Res Function(FirebaseDocument) _then) = _$FirebaseDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String url, String name
});




}
/// @nodoc
class _$FirebaseDocumentCopyWithImpl<$Res>
    implements $FirebaseDocumentCopyWith<$Res> {
  _$FirebaseDocumentCopyWithImpl(this._self, this._then);

  final FirebaseDocument _self;
  final $Res Function(FirebaseDocument) _then;

/// Create a copy of FirebaseDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FirebaseDocument implements FirebaseDocument {
  const _FirebaseDocument({required this.id, required this.url, required this.name});
  factory _FirebaseDocument.fromJson(Map<String, dynamic> json) => _$FirebaseDocumentFromJson(json);

@override final  String id;
@override final  String url;
@override final  String name;

/// Create a copy of FirebaseDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FirebaseDocumentCopyWith<_FirebaseDocument> get copyWith => __$FirebaseDocumentCopyWithImpl<_FirebaseDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FirebaseDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FirebaseDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,name);

@override
String toString() {
  return 'FirebaseDocument(id: $id, url: $url, name: $name)';
}


}

/// @nodoc
abstract mixin class _$FirebaseDocumentCopyWith<$Res> implements $FirebaseDocumentCopyWith<$Res> {
  factory _$FirebaseDocumentCopyWith(_FirebaseDocument value, $Res Function(_FirebaseDocument) _then) = __$FirebaseDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String name
});




}
/// @nodoc
class __$FirebaseDocumentCopyWithImpl<$Res>
    implements _$FirebaseDocumentCopyWith<$Res> {
  __$FirebaseDocumentCopyWithImpl(this._self, this._then);

  final _FirebaseDocument _self;
  final $Res Function(_FirebaseDocument) _then;

/// Create a copy of FirebaseDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? name = null,}) {
  return _then(_FirebaseDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
