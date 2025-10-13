// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SummaryList {

 String get count; Map<String, String> get amountPerType; int get totalValue; double get totalWeight;
/// Create a copy of SummaryList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryListCopyWith<SummaryList> get copyWith => _$SummaryListCopyWithImpl<SummaryList>(this as SummaryList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryList&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.amountPerType, amountPerType)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight));
}


@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(amountPerType),totalValue,totalWeight);

@override
String toString() {
  return 'SummaryList(count: $count, amountPerType: $amountPerType, totalValue: $totalValue, totalWeight: $totalWeight)';
}


}

/// @nodoc
abstract mixin class $SummaryListCopyWith<$Res>  {
  factory $SummaryListCopyWith(SummaryList value, $Res Function(SummaryList) _then) = _$SummaryListCopyWithImpl;
@useResult
$Res call({
 String count, Map<String, String> amountPerType, int totalValue, double totalWeight
});




}
/// @nodoc
class _$SummaryListCopyWithImpl<$Res>
    implements $SummaryListCopyWith<$Res> {
  _$SummaryListCopyWithImpl(this._self, this._then);

  final SummaryList _self;
  final $Res Function(SummaryList) _then;

/// Create a copy of SummaryList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? amountPerType = null,Object? totalValue = null,Object? totalWeight = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as String,amountPerType: null == amountPerType ? _self.amountPerType : amountPerType // ignore: cast_nullable_to_non_nullable
as Map<String, String>,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as int,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryList].
extension SummaryListPatterns on SummaryList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryList value)  $default,){
final _that = this;
switch (_that) {
case _SummaryList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryList value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String count,  Map<String, String> amountPerType,  int totalValue,  double totalWeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryList() when $default != null:
return $default(_that.count,_that.amountPerType,_that.totalValue,_that.totalWeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String count,  Map<String, String> amountPerType,  int totalValue,  double totalWeight)  $default,) {final _that = this;
switch (_that) {
case _SummaryList():
return $default(_that.count,_that.amountPerType,_that.totalValue,_that.totalWeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String count,  Map<String, String> amountPerType,  int totalValue,  double totalWeight)?  $default,) {final _that = this;
switch (_that) {
case _SummaryList() when $default != null:
return $default(_that.count,_that.amountPerType,_that.totalValue,_that.totalWeight);case _:
  return null;

}
}

}

/// @nodoc


class _SummaryList implements SummaryList {
  const _SummaryList({required this.count, required final  Map<String, String> amountPerType, required this.totalValue, required this.totalWeight}): _amountPerType = amountPerType;
  

@override final  String count;
 final  Map<String, String> _amountPerType;
@override Map<String, String> get amountPerType {
  if (_amountPerType is EqualUnmodifiableMapView) return _amountPerType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_amountPerType);
}

@override final  int totalValue;
@override final  double totalWeight;

/// Create a copy of SummaryList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryListCopyWith<_SummaryList> get copyWith => __$SummaryListCopyWithImpl<_SummaryList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryList&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._amountPerType, _amountPerType)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight));
}


@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(_amountPerType),totalValue,totalWeight);

@override
String toString() {
  return 'SummaryList(count: $count, amountPerType: $amountPerType, totalValue: $totalValue, totalWeight: $totalWeight)';
}


}

/// @nodoc
abstract mixin class _$SummaryListCopyWith<$Res> implements $SummaryListCopyWith<$Res> {
  factory _$SummaryListCopyWith(_SummaryList value, $Res Function(_SummaryList) _then) = __$SummaryListCopyWithImpl;
@override @useResult
$Res call({
 String count, Map<String, String> amountPerType, int totalValue, double totalWeight
});




}
/// @nodoc
class __$SummaryListCopyWithImpl<$Res>
    implements _$SummaryListCopyWith<$Res> {
  __$SummaryListCopyWithImpl(this._self, this._then);

  final _SummaryList _self;
  final $Res Function(_SummaryList) _then;

/// Create a copy of SummaryList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? amountPerType = null,Object? totalValue = null,Object? totalWeight = null,}) {
  return _then(_SummaryList(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as String,amountPerType: null == amountPerType ? _self._amountPerType : amountPerType // ignore: cast_nullable_to_non_nullable
as Map<String, String>,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as int,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
