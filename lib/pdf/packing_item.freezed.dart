// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packing_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PackingItem {

 String get name; String get description; double get amount; double get piecePrice; double get weightTotal; DateTime? get expirationDate; String get dangerousGoods; String get remarks;
/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackingItemCopyWith<PackingItem> get copyWith => _$PackingItemCopyWithImpl<PackingItem>(this as PackingItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackingItem&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.piecePrice, piecePrice) || other.piecePrice == piecePrice)&&(identical(other.weightTotal, weightTotal) || other.weightTotal == weightTotal)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.dangerousGoods, dangerousGoods) || other.dangerousGoods == dangerousGoods)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,amount,piecePrice,weightTotal,expirationDate,dangerousGoods,remarks);

@override
String toString() {
  return 'PackingItem(name: $name, description: $description, amount: $amount, piecePrice: $piecePrice, weightTotal: $weightTotal, expirationDate: $expirationDate, dangerousGoods: $dangerousGoods, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $PackingItemCopyWith<$Res>  {
  factory $PackingItemCopyWith(PackingItem value, $Res Function(PackingItem) _then) = _$PackingItemCopyWithImpl;
@useResult
$Res call({
 String name, String description, double amount, double piecePrice, double weightTotal, DateTime? expirationDate, String dangerousGoods, String remarks
});




}
/// @nodoc
class _$PackingItemCopyWithImpl<$Res>
    implements $PackingItemCopyWith<$Res> {
  _$PackingItemCopyWithImpl(this._self, this._then);

  final PackingItem _self;
  final $Res Function(PackingItem) _then;

/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? amount = null,Object? piecePrice = null,Object? weightTotal = null,Object? expirationDate = freezed,Object? dangerousGoods = null,Object? remarks = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,piecePrice: null == piecePrice ? _self.piecePrice : piecePrice // ignore: cast_nullable_to_non_nullable
as double,weightTotal: null == weightTotal ? _self.weightTotal : weightTotal // ignore: cast_nullable_to_non_nullable
as double,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dangerousGoods: null == dangerousGoods ? _self.dangerousGoods : dangerousGoods // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PackingItem].
extension PackingItemPatterns on PackingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackingItem value)  $default,){
final _that = this;
switch (_that) {
case _PackingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackingItem value)?  $default,){
final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  double amount,  double piecePrice,  double weightTotal,  DateTime? expirationDate,  String dangerousGoods,  String remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
return $default(_that.name,_that.description,_that.amount,_that.piecePrice,_that.weightTotal,_that.expirationDate,_that.dangerousGoods,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  double amount,  double piecePrice,  double weightTotal,  DateTime? expirationDate,  String dangerousGoods,  String remarks)  $default,) {final _that = this;
switch (_that) {
case _PackingItem():
return $default(_that.name,_that.description,_that.amount,_that.piecePrice,_that.weightTotal,_that.expirationDate,_that.dangerousGoods,_that.remarks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  double amount,  double piecePrice,  double weightTotal,  DateTime? expirationDate,  String dangerousGoods,  String remarks)?  $default,) {final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
return $default(_that.name,_that.description,_that.amount,_that.piecePrice,_that.weightTotal,_that.expirationDate,_that.dangerousGoods,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc


class _PackingItem implements PackingItem {
  const _PackingItem({required this.name, required this.description, required this.amount, required this.piecePrice, required this.weightTotal, required this.expirationDate, required this.dangerousGoods, required this.remarks});
  

@override final  String name;
@override final  String description;
@override final  double amount;
@override final  double piecePrice;
@override final  double weightTotal;
@override final  DateTime? expirationDate;
@override final  String dangerousGoods;
@override final  String remarks;

/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackingItemCopyWith<_PackingItem> get copyWith => __$PackingItemCopyWithImpl<_PackingItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackingItem&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.piecePrice, piecePrice) || other.piecePrice == piecePrice)&&(identical(other.weightTotal, weightTotal) || other.weightTotal == weightTotal)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.dangerousGoods, dangerousGoods) || other.dangerousGoods == dangerousGoods)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,amount,piecePrice,weightTotal,expirationDate,dangerousGoods,remarks);

@override
String toString() {
  return 'PackingItem(name: $name, description: $description, amount: $amount, piecePrice: $piecePrice, weightTotal: $weightTotal, expirationDate: $expirationDate, dangerousGoods: $dangerousGoods, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$PackingItemCopyWith<$Res> implements $PackingItemCopyWith<$Res> {
  factory _$PackingItemCopyWith(_PackingItem value, $Res Function(_PackingItem) _then) = __$PackingItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, double amount, double piecePrice, double weightTotal, DateTime? expirationDate, String dangerousGoods, String remarks
});




}
/// @nodoc
class __$PackingItemCopyWithImpl<$Res>
    implements _$PackingItemCopyWith<$Res> {
  __$PackingItemCopyWithImpl(this._self, this._then);

  final _PackingItem _self;
  final $Res Function(_PackingItem) _then;

/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? amount = null,Object? piecePrice = null,Object? weightTotal = null,Object? expirationDate = freezed,Object? dangerousGoods = null,Object? remarks = null,}) {
  return _then(_PackingItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,piecePrice: null == piecePrice ? _self.piecePrice : piecePrice // ignore: cast_nullable_to_non_nullable
as double,weightTotal: null == weightTotal ? _self.weightTotal : weightTotal // ignore: cast_nullable_to_non_nullable
as double,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dangerousGoods: null == dangerousGoods ? _self.dangerousGoods : dangerousGoods // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
