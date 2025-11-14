// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packing_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PackingList {

 int get containerNo; String get containerType; String get containerName; String get containerDescription; double get totalWeight; String get destination; int get priority; SequentialBuild get sequentialBuild; DateTime? get expirationDate; List<PackingDangerousGood> get dangerousGoods; List<PackingItem> get items;
/// Create a copy of PackingList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackingListCopyWith<PackingList> get copyWith => _$PackingListCopyWithImpl<PackingList>(this as PackingList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackingList&&(identical(other.containerNo, containerNo) || other.containerNo == containerNo)&&(identical(other.containerType, containerType) || other.containerType == containerType)&&(identical(other.containerName, containerName) || other.containerName == containerName)&&(identical(other.containerDescription, containerDescription) || other.containerDescription == containerDescription)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&const DeepCollectionEquality().equals(other.dangerousGoods, dangerousGoods)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,containerNo,containerType,containerName,containerDescription,totalWeight,destination,priority,sequentialBuild,expirationDate,const DeepCollectionEquality().hash(dangerousGoods),const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PackingList(containerNo: $containerNo, containerType: $containerType, containerName: $containerName, containerDescription: $containerDescription, totalWeight: $totalWeight, destination: $destination, priority: $priority, sequentialBuild: $sequentialBuild, expirationDate: $expirationDate, dangerousGoods: $dangerousGoods, items: $items)';
}


}

/// @nodoc
abstract mixin class $PackingListCopyWith<$Res>  {
  factory $PackingListCopyWith(PackingList value, $Res Function(PackingList) _then) = _$PackingListCopyWithImpl;
@useResult
$Res call({
 int containerNo, String containerType, String containerName, String containerDescription, double totalWeight, String destination, int priority, SequentialBuild sequentialBuild, DateTime? expirationDate, List<PackingDangerousGood> dangerousGoods, List<PackingItem> items
});




}
/// @nodoc
class _$PackingListCopyWithImpl<$Res>
    implements $PackingListCopyWith<$Res> {
  _$PackingListCopyWithImpl(this._self, this._then);

  final PackingList _self;
  final $Res Function(PackingList) _then;

/// Create a copy of PackingList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? containerNo = null,Object? containerType = null,Object? containerName = null,Object? containerDescription = null,Object? totalWeight = null,Object? destination = null,Object? priority = null,Object? sequentialBuild = null,Object? expirationDate = freezed,Object? dangerousGoods = null,Object? items = null,}) {
  return _then(_self.copyWith(
containerNo: null == containerNo ? _self.containerNo : containerNo // ignore: cast_nullable_to_non_nullable
as int,containerType: null == containerType ? _self.containerType : containerType // ignore: cast_nullable_to_non_nullable
as String,containerName: null == containerName ? _self.containerName : containerName // ignore: cast_nullable_to_non_nullable
as String,containerDescription: null == containerDescription ? _self.containerDescription : containerDescription // ignore: cast_nullable_to_non_nullable
as String,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as double,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dangerousGoods: null == dangerousGoods ? _self.dangerousGoods : dangerousGoods // ignore: cast_nullable_to_non_nullable
as List<PackingDangerousGood>,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PackingItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackingList].
extension PackingListPatterns on PackingList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackingList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackingList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackingList value)  $default,){
final _that = this;
switch (_that) {
case _PackingList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackingList value)?  $default,){
final _that = this;
switch (_that) {
case _PackingList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int containerNo,  String containerType,  String containerName,  String containerDescription,  double totalWeight,  String destination,  int priority,  SequentialBuild sequentialBuild,  DateTime? expirationDate,  List<PackingDangerousGood> dangerousGoods,  List<PackingItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackingList() when $default != null:
return $default(_that.containerNo,_that.containerType,_that.containerName,_that.containerDescription,_that.totalWeight,_that.destination,_that.priority,_that.sequentialBuild,_that.expirationDate,_that.dangerousGoods,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int containerNo,  String containerType,  String containerName,  String containerDescription,  double totalWeight,  String destination,  int priority,  SequentialBuild sequentialBuild,  DateTime? expirationDate,  List<PackingDangerousGood> dangerousGoods,  List<PackingItem> items)  $default,) {final _that = this;
switch (_that) {
case _PackingList():
return $default(_that.containerNo,_that.containerType,_that.containerName,_that.containerDescription,_that.totalWeight,_that.destination,_that.priority,_that.sequentialBuild,_that.expirationDate,_that.dangerousGoods,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int containerNo,  String containerType,  String containerName,  String containerDescription,  double totalWeight,  String destination,  int priority,  SequentialBuild sequentialBuild,  DateTime? expirationDate,  List<PackingDangerousGood> dangerousGoods,  List<PackingItem> items)?  $default,) {final _that = this;
switch (_that) {
case _PackingList() when $default != null:
return $default(_that.containerNo,_that.containerType,_that.containerName,_that.containerDescription,_that.totalWeight,_that.destination,_that.priority,_that.sequentialBuild,_that.expirationDate,_that.dangerousGoods,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _PackingList implements PackingList {
  const _PackingList({required this.containerNo, required this.containerType, required this.containerName, required this.containerDescription, required this.totalWeight, required this.destination, this.priority = 1, required this.sequentialBuild, required this.expirationDate, required final  List<PackingDangerousGood> dangerousGoods, required final  List<PackingItem> items}): _dangerousGoods = dangerousGoods,_items = items;
  

@override final  int containerNo;
@override final  String containerType;
@override final  String containerName;
@override final  String containerDescription;
@override final  double totalWeight;
@override final  String destination;
@override@JsonKey() final  int priority;
@override final  SequentialBuild sequentialBuild;
@override final  DateTime? expirationDate;
 final  List<PackingDangerousGood> _dangerousGoods;
@override List<PackingDangerousGood> get dangerousGoods {
  if (_dangerousGoods is EqualUnmodifiableListView) return _dangerousGoods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dangerousGoods);
}

 final  List<PackingItem> _items;
@override List<PackingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of PackingList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackingListCopyWith<_PackingList> get copyWith => __$PackingListCopyWithImpl<_PackingList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackingList&&(identical(other.containerNo, containerNo) || other.containerNo == containerNo)&&(identical(other.containerType, containerType) || other.containerType == containerType)&&(identical(other.containerName, containerName) || other.containerName == containerName)&&(identical(other.containerDescription, containerDescription) || other.containerDescription == containerDescription)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.sequentialBuild, sequentialBuild) || other.sequentialBuild == sequentialBuild)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&const DeepCollectionEquality().equals(other._dangerousGoods, _dangerousGoods)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,containerNo,containerType,containerName,containerDescription,totalWeight,destination,priority,sequentialBuild,expirationDate,const DeepCollectionEquality().hash(_dangerousGoods),const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PackingList(containerNo: $containerNo, containerType: $containerType, containerName: $containerName, containerDescription: $containerDescription, totalWeight: $totalWeight, destination: $destination, priority: $priority, sequentialBuild: $sequentialBuild, expirationDate: $expirationDate, dangerousGoods: $dangerousGoods, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PackingListCopyWith<$Res> implements $PackingListCopyWith<$Res> {
  factory _$PackingListCopyWith(_PackingList value, $Res Function(_PackingList) _then) = __$PackingListCopyWithImpl;
@override @useResult
$Res call({
 int containerNo, String containerType, String containerName, String containerDescription, double totalWeight, String destination, int priority, SequentialBuild sequentialBuild, DateTime? expirationDate, List<PackingDangerousGood> dangerousGoods, List<PackingItem> items
});




}
/// @nodoc
class __$PackingListCopyWithImpl<$Res>
    implements _$PackingListCopyWith<$Res> {
  __$PackingListCopyWithImpl(this._self, this._then);

  final _PackingList _self;
  final $Res Function(_PackingList) _then;

/// Create a copy of PackingList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? containerNo = null,Object? containerType = null,Object? containerName = null,Object? containerDescription = null,Object? totalWeight = null,Object? destination = null,Object? priority = null,Object? sequentialBuild = null,Object? expirationDate = freezed,Object? dangerousGoods = null,Object? items = null,}) {
  return _then(_PackingList(
containerNo: null == containerNo ? _self.containerNo : containerNo // ignore: cast_nullable_to_non_nullable
as int,containerType: null == containerType ? _self.containerType : containerType // ignore: cast_nullable_to_non_nullable
as String,containerName: null == containerName ? _self.containerName : containerName // ignore: cast_nullable_to_non_nullable
as String,containerDescription: null == containerDescription ? _self.containerDescription : containerDescription // ignore: cast_nullable_to_non_nullable
as String,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as double,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,sequentialBuild: null == sequentialBuild ? _self.sequentialBuild : sequentialBuild // ignore: cast_nullable_to_non_nullable
as SequentialBuild,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dangerousGoods: null == dangerousGoods ? _self._dangerousGoods : dangerousGoods // ignore: cast_nullable_to_non_nullable
as List<PackingDangerousGood>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PackingItem>,
  ));
}


}

// dart format on
