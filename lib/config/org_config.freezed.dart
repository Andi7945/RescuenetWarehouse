// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'org_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrgConfig {

/// Unique organization identifier (e.g., 'rescuenet')
 String get id;/// Display name for the organization (e.g., 'RescueNet')
 String get name;/// Optional path to organization logo in assets
 String? get logoAssetPath;/// Optional organization primary brand color
 Color? get primaryColor;/// Firebase options for production environment
 FirebaseOptions get productionFirebase;/// Firebase options for staging environment
 FirebaseOptions get stagingFirebase;/// Optional feature flags for org-specific features
 Map<String, dynamic> get features;
/// Create a copy of OrgConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgConfigCopyWith<OrgConfig> get copyWith => _$OrgConfigCopyWithImpl<OrgConfig>(this as OrgConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoAssetPath, logoAssetPath) || other.logoAssetPath == logoAssetPath)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.productionFirebase, productionFirebase) || other.productionFirebase == productionFirebase)&&(identical(other.stagingFirebase, stagingFirebase) || other.stagingFirebase == stagingFirebase)&&const DeepCollectionEquality().equals(other.features, features));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,logoAssetPath,primaryColor,productionFirebase,stagingFirebase,const DeepCollectionEquality().hash(features));

@override
String toString() {
  return 'OrgConfig(id: $id, name: $name, logoAssetPath: $logoAssetPath, primaryColor: $primaryColor, productionFirebase: $productionFirebase, stagingFirebase: $stagingFirebase, features: $features)';
}


}

/// @nodoc
abstract mixin class $OrgConfigCopyWith<$Res>  {
  factory $OrgConfigCopyWith(OrgConfig value, $Res Function(OrgConfig) _then) = _$OrgConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? logoAssetPath, Color? primaryColor, FirebaseOptions productionFirebase, FirebaseOptions stagingFirebase, Map<String, dynamic> features
});




}
/// @nodoc
class _$OrgConfigCopyWithImpl<$Res>
    implements $OrgConfigCopyWith<$Res> {
  _$OrgConfigCopyWithImpl(this._self, this._then);

  final OrgConfig _self;
  final $Res Function(OrgConfig) _then;

/// Create a copy of OrgConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logoAssetPath = freezed,Object? primaryColor = freezed,Object? productionFirebase = null,Object? stagingFirebase = null,Object? features = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoAssetPath: freezed == logoAssetPath ? _self.logoAssetPath : logoAssetPath // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as Color?,productionFirebase: null == productionFirebase ? _self.productionFirebase : productionFirebase // ignore: cast_nullable_to_non_nullable
as FirebaseOptions,stagingFirebase: null == stagingFirebase ? _self.stagingFirebase : stagingFirebase // ignore: cast_nullable_to_non_nullable
as FirebaseOptions,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgConfig].
extension OrgConfigPatterns on OrgConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgConfig value)  $default,){
final _that = this;
switch (_that) {
case _OrgConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgConfig value)?  $default,){
final _that = this;
switch (_that) {
case _OrgConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? logoAssetPath,  Color? primaryColor,  FirebaseOptions productionFirebase,  FirebaseOptions stagingFirebase,  Map<String, dynamic> features)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgConfig() when $default != null:
return $default(_that.id,_that.name,_that.logoAssetPath,_that.primaryColor,_that.productionFirebase,_that.stagingFirebase,_that.features);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? logoAssetPath,  Color? primaryColor,  FirebaseOptions productionFirebase,  FirebaseOptions stagingFirebase,  Map<String, dynamic> features)  $default,) {final _that = this;
switch (_that) {
case _OrgConfig():
return $default(_that.id,_that.name,_that.logoAssetPath,_that.primaryColor,_that.productionFirebase,_that.stagingFirebase,_that.features);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? logoAssetPath,  Color? primaryColor,  FirebaseOptions productionFirebase,  FirebaseOptions stagingFirebase,  Map<String, dynamic> features)?  $default,) {final _that = this;
switch (_that) {
case _OrgConfig() when $default != null:
return $default(_that.id,_that.name,_that.logoAssetPath,_that.primaryColor,_that.productionFirebase,_that.stagingFirebase,_that.features);case _:
  return null;

}
}

}

/// @nodoc


class _OrgConfig implements OrgConfig {
  const _OrgConfig({required this.id, required this.name, this.logoAssetPath, this.primaryColor, required this.productionFirebase, required this.stagingFirebase, final  Map<String, dynamic> features = const {}}): _features = features;
  

/// Unique organization identifier (e.g., 'rescuenet')
@override final  String id;
/// Display name for the organization (e.g., 'RescueNet')
@override final  String name;
/// Optional path to organization logo in assets
@override final  String? logoAssetPath;
/// Optional organization primary brand color
@override final  Color? primaryColor;
/// Firebase options for production environment
@override final  FirebaseOptions productionFirebase;
/// Firebase options for staging environment
@override final  FirebaseOptions stagingFirebase;
/// Optional feature flags for org-specific features
 final  Map<String, dynamic> _features;
/// Optional feature flags for org-specific features
@override@JsonKey() Map<String, dynamic> get features {
  if (_features is EqualUnmodifiableMapView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_features);
}


/// Create a copy of OrgConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgConfigCopyWith<_OrgConfig> get copyWith => __$OrgConfigCopyWithImpl<_OrgConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoAssetPath, logoAssetPath) || other.logoAssetPath == logoAssetPath)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.productionFirebase, productionFirebase) || other.productionFirebase == productionFirebase)&&(identical(other.stagingFirebase, stagingFirebase) || other.stagingFirebase == stagingFirebase)&&const DeepCollectionEquality().equals(other._features, _features));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,logoAssetPath,primaryColor,productionFirebase,stagingFirebase,const DeepCollectionEquality().hash(_features));

@override
String toString() {
  return 'OrgConfig(id: $id, name: $name, logoAssetPath: $logoAssetPath, primaryColor: $primaryColor, productionFirebase: $productionFirebase, stagingFirebase: $stagingFirebase, features: $features)';
}


}

/// @nodoc
abstract mixin class _$OrgConfigCopyWith<$Res> implements $OrgConfigCopyWith<$Res> {
  factory _$OrgConfigCopyWith(_OrgConfig value, $Res Function(_OrgConfig) _then) = __$OrgConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? logoAssetPath, Color? primaryColor, FirebaseOptions productionFirebase, FirebaseOptions stagingFirebase, Map<String, dynamic> features
});




}
/// @nodoc
class __$OrgConfigCopyWithImpl<$Res>
    implements _$OrgConfigCopyWith<$Res> {
  __$OrgConfigCopyWithImpl(this._self, this._then);

  final _OrgConfig _self;
  final $Res Function(_OrgConfig) _then;

/// Create a copy of OrgConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logoAssetPath = freezed,Object? primaryColor = freezed,Object? productionFirebase = null,Object? stagingFirebase = null,Object? features = null,}) {
  return _then(_OrgConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoAssetPath: freezed == logoAssetPath ? _self.logoAssetPath : logoAssetPath // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as Color?,productionFirebase: null == productionFirebase ? _self.productionFirebase : productionFirebase // ignore: cast_nullable_to_non_nullable
as FirebaseOptions,stagingFirebase: null == stagingFirebase ? _self.stagingFirebase : stagingFirebase // ignore: cast_nullable_to_non_nullable
as FirebaseOptions,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
