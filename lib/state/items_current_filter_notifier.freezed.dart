// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'items_current_filter_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CurrentItemFilter {

 ItemFilter get filter; String? get value;
/// Create a copy of CurrentItemFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentItemFilterCopyWith<CurrentItemFilter> get copyWith => _$CurrentItemFilterCopyWithImpl<CurrentItemFilter>(this as CurrentItemFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentItemFilter&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,filter,value);

@override
String toString() {
  return 'CurrentItemFilter(filter: $filter, value: $value)';
}


}

/// @nodoc
abstract mixin class $CurrentItemFilterCopyWith<$Res>  {
  factory $CurrentItemFilterCopyWith(CurrentItemFilter value, $Res Function(CurrentItemFilter) _then) = _$CurrentItemFilterCopyWithImpl;
@useResult
$Res call({
 ItemFilter filter, String? value
});




}
/// @nodoc
class _$CurrentItemFilterCopyWithImpl<$Res>
    implements $CurrentItemFilterCopyWith<$Res> {
  _$CurrentItemFilterCopyWithImpl(this._self, this._then);

  final CurrentItemFilter _self;
  final $Res Function(CurrentItemFilter) _then;

/// Create a copy of CurrentItemFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filter = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ItemFilter,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _CurrentItemFilter implements CurrentItemFilter {
   _CurrentItemFilter({required this.filter, required this.value});
  

@override final  ItemFilter filter;
@override final  String? value;

/// Create a copy of CurrentItemFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentItemFilterCopyWith<_CurrentItemFilter> get copyWith => __$CurrentItemFilterCopyWithImpl<_CurrentItemFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentItemFilter&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,filter,value);

@override
String toString() {
  return 'CurrentItemFilter(filter: $filter, value: $value)';
}


}

/// @nodoc
abstract mixin class _$CurrentItemFilterCopyWith<$Res> implements $CurrentItemFilterCopyWith<$Res> {
  factory _$CurrentItemFilterCopyWith(_CurrentItemFilter value, $Res Function(_CurrentItemFilter) _then) = __$CurrentItemFilterCopyWithImpl;
@override @useResult
$Res call({
 ItemFilter filter, String? value
});




}
/// @nodoc
class __$CurrentItemFilterCopyWithImpl<$Res>
    implements _$CurrentItemFilterCopyWith<$Res> {
  __$CurrentItemFilterCopyWithImpl(this._self, this._then);

  final _CurrentItemFilter _self;
  final $Res Function(_CurrentItemFilter) _then;

/// Create a copy of CurrentItemFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filter = null,Object? value = freezed,}) {
  return _then(_CurrentItemFilter(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ItemFilter,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
