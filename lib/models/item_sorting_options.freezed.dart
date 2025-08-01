// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_sorting_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItemSortingOption {

 String get displayName; String? Function(Item item) get value; int Function(Item a, Item b) get sort; bool get asc;
/// Create a copy of ItemSortingOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemSortingOptionCopyWith<ItemSortingOption> get copyWith => _$ItemSortingOptionCopyWithImpl<ItemSortingOption>(this as ItemSortingOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemSortingOption&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.value, value) || other.value == value)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.asc, asc) || other.asc == asc));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,value,sort,asc);

@override
String toString() {
  return 'ItemSortingOption(displayName: $displayName, value: $value, sort: $sort, asc: $asc)';
}


}

/// @nodoc
abstract mixin class $ItemSortingOptionCopyWith<$Res>  {
  factory $ItemSortingOptionCopyWith(ItemSortingOption value, $Res Function(ItemSortingOption) _then) = _$ItemSortingOptionCopyWithImpl;
@useResult
$Res call({
 String displayName, String? Function(Item item) value, int Function(Item a, Item b) sort, bool asc
});




}
/// @nodoc
class _$ItemSortingOptionCopyWithImpl<$Res>
    implements $ItemSortingOptionCopyWith<$Res> {
  _$ItemSortingOptionCopyWithImpl(this._self, this._then);

  final ItemSortingOption _self;
  final $Res Function(ItemSortingOption) _then;

/// Create a copy of ItemSortingOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? value = null,Object? sort = null,Object? asc = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String? Function(Item item),sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int Function(Item a, Item b),asc: null == asc ? _self.asc : asc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemSortingOption].
extension ItemSortingOptionPatterns on ItemSortingOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemSortingOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemSortingOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemSortingOption value)  $default,){
final _that = this;
switch (_that) {
case _ItemSortingOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemSortingOption value)?  $default,){
final _that = this;
switch (_that) {
case _ItemSortingOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  String? Function(Item item) value,  int Function(Item a, Item b) sort,  bool asc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemSortingOption() when $default != null:
return $default(_that.displayName,_that.value,_that.sort,_that.asc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  String? Function(Item item) value,  int Function(Item a, Item b) sort,  bool asc)  $default,) {final _that = this;
switch (_that) {
case _ItemSortingOption():
return $default(_that.displayName,_that.value,_that.sort,_that.asc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  String? Function(Item item) value,  int Function(Item a, Item b) sort,  bool asc)?  $default,) {final _that = this;
switch (_that) {
case _ItemSortingOption() when $default != null:
return $default(_that.displayName,_that.value,_that.sort,_that.asc);case _:
  return null;

}
}

}

/// @nodoc


class _ItemSortingOption implements ItemSortingOption {
  const _ItemSortingOption({required this.displayName, required this.value, required this.sort, this.asc = true});
  

@override final  String displayName;
@override final  String? Function(Item item) value;
@override final  int Function(Item a, Item b) sort;
@override@JsonKey() final  bool asc;

/// Create a copy of ItemSortingOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemSortingOptionCopyWith<_ItemSortingOption> get copyWith => __$ItemSortingOptionCopyWithImpl<_ItemSortingOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemSortingOption&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.value, value) || other.value == value)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.asc, asc) || other.asc == asc));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,value,sort,asc);

@override
String toString() {
  return 'ItemSortingOption(displayName: $displayName, value: $value, sort: $sort, asc: $asc)';
}


}

/// @nodoc
abstract mixin class _$ItemSortingOptionCopyWith<$Res> implements $ItemSortingOptionCopyWith<$Res> {
  factory _$ItemSortingOptionCopyWith(_ItemSortingOption value, $Res Function(_ItemSortingOption) _then) = __$ItemSortingOptionCopyWithImpl;
@override @useResult
$Res call({
 String displayName, String? Function(Item item) value, int Function(Item a, Item b) sort, bool asc
});




}
/// @nodoc
class __$ItemSortingOptionCopyWithImpl<$Res>
    implements _$ItemSortingOptionCopyWith<$Res> {
  __$ItemSortingOptionCopyWithImpl(this._self, this._then);

  final _ItemSortingOption _self;
  final $Res Function(_ItemSortingOption) _then;

/// Create a copy of ItemSortingOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? value = null,Object? sort = null,Object? asc = null,}) {
  return _then(_ItemSortingOption(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String? Function(Item item),sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int Function(Item a, Item b),asc: null == asc ? _self.asc : asc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
