// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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

 String get id; String get name;/// Load priority 1 (first) .. 4 (last). `null` means not configured yet -
/// such destinations sort last. Nullable because existing Firestore
/// documents predate this field.
 int? get priority; PriorityBadgeShape? get badgeShape;
/// Create a copy of ModuleDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleDestinationCopyWith<ModuleDestination> get copyWith => _$ModuleDestinationCopyWithImpl<ModuleDestination>(this as ModuleDestination, _$identity);

  /// Serializes this ModuleDestination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleDestination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.badgeShape, badgeShape) || other.badgeShape == badgeShape));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,priority,badgeShape);

@override
String toString() {
  return 'ModuleDestination(id: $id, name: $name, priority: $priority, badgeShape: $badgeShape)';
}


}

/// @nodoc
abstract mixin class $ModuleDestinationCopyWith<$Res>  {
  factory $ModuleDestinationCopyWith(ModuleDestination value, $Res Function(ModuleDestination) _then) = _$ModuleDestinationCopyWithImpl;
@useResult
$Res call({
 String id, String name, int? priority, PriorityBadgeShape? badgeShape
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? priority = freezed,Object? badgeShape = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int?,badgeShape: freezed == badgeShape ? _self.badgeShape : badgeShape // ignore: cast_nullable_to_non_nullable
as PriorityBadgeShape?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModuleDestination].
extension ModuleDestinationPatterns on ModuleDestination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModuleDestination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModuleDestination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModuleDestination value)  $default,){
final _that = this;
switch (_that) {
case _ModuleDestination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModuleDestination value)?  $default,){
final _that = this;
switch (_that) {
case _ModuleDestination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int? priority,  PriorityBadgeShape? badgeShape)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModuleDestination() when $default != null:
return $default(_that.id,_that.name,_that.priority,_that.badgeShape);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int? priority,  PriorityBadgeShape? badgeShape)  $default,) {final _that = this;
switch (_that) {
case _ModuleDestination():
return $default(_that.id,_that.name,_that.priority,_that.badgeShape);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int? priority,  PriorityBadgeShape? badgeShape)?  $default,) {final _that = this;
switch (_that) {
case _ModuleDestination() when $default != null:
return $default(_that.id,_that.name,_that.priority,_that.badgeShape);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModuleDestination implements ModuleDestination {
  const _ModuleDestination({required this.id, required this.name, this.priority, this.badgeShape});
  factory _ModuleDestination.fromJson(Map<String, dynamic> json) => _$ModuleDestinationFromJson(json);

@override final  String id;
@override final  String name;
/// Load priority 1 (first) .. 4 (last). `null` means not configured yet -
/// such destinations sort last. Nullable because existing Firestore
/// documents predate this field.
@override final  int? priority;
@override final  PriorityBadgeShape? badgeShape;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleDestination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.badgeShape, badgeShape) || other.badgeShape == badgeShape));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,priority,badgeShape);

@override
String toString() {
  return 'ModuleDestination(id: $id, name: $name, priority: $priority, badgeShape: $badgeShape)';
}


}

/// @nodoc
abstract mixin class _$ModuleDestinationCopyWith<$Res> implements $ModuleDestinationCopyWith<$Res> {
  factory _$ModuleDestinationCopyWith(_ModuleDestination value, $Res Function(_ModuleDestination) _then) = __$ModuleDestinationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int? priority, PriorityBadgeShape? badgeShape
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? priority = freezed,Object? badgeShape = freezed,}) {
  return _then(_ModuleDestination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int?,badgeShape: freezed == badgeShape ? _self.badgeShape : badgeShape // ignore: cast_nullable_to_non_nullable
as PriorityBadgeShape?,
  ));
}


}

// dart format on
