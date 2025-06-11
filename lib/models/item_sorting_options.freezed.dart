// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
 String displayName, String? Function(Item) value, int Function(Item, Item) sort, bool asc
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
as String,value: null == value ? _self.value! : value // ignore: cast_nullable_to_non_nullable
as String? Function(Item),sort: null == sort ? _self.sort! : sort // ignore: cast_nullable_to_non_nullable
as int Function(Item, Item),asc: null == asc ? _self.asc : asc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _ItemSortingOption implements ItemSortingOption {
  const _ItemSortingOption({required this.displayName, required this.value, required this.sort, this.asc = true});
  

@override final  String displayName;
@override final  String? Function(Item) value;
@override final  int Function(Item, Item) sort;
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
 String displayName, String? Function(Item) value, int Function(Item, Item) sort, bool asc
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
as String? Function(Item),sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int Function(Item, Item),asc: null == asc ? _self.asc : asc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
