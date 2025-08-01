// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Item {

 String get id; String? get name; String get imagePath; double get rescueNetId; double get weight; int get totalAmount; String? get description;@TimestampConverter() List<DateTime> get expiringDates; OperationalStatus get operationalStatus;@StringConverter() String? get manufacturer;@StringConverter() String? get brand;@StringConverter() String? get type;@StringConverter() String? get supplier;@StringConverter() String? get website;@StringConverter() String? get remarks; int get value;@StringConverter() String? get sku; String? get notes; List<Sign> get signs; bool get isColdChain;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.rescueNetId, rescueNetId) || other.rescueNetId == rescueNetId)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.expiringDates, expiringDates)&&(identical(other.operationalStatus, operationalStatus) || other.operationalStatus == operationalStatus)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.type, type) || other.type == type)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.website, website) || other.website == website)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.value, value) || other.value == value)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.signs, signs)&&(identical(other.isColdChain, isColdChain) || other.isColdChain == isColdChain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,imagePath,rescueNetId,weight,totalAmount,description,const DeepCollectionEquality().hash(expiringDates),operationalStatus,manufacturer,brand,type,supplier,website,remarks,value,sku,notes,const DeepCollectionEquality().hash(signs),isColdChain]);

@override
String toString() {
  return 'Item(id: $id, name: $name, imagePath: $imagePath, rescueNetId: $rescueNetId, weight: $weight, totalAmount: $totalAmount, description: $description, expiringDates: $expiringDates, operationalStatus: $operationalStatus, manufacturer: $manufacturer, brand: $brand, type: $type, supplier: $supplier, website: $website, remarks: $remarks, value: $value, sku: $sku, notes: $notes, signs: $signs, isColdChain: $isColdChain)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String imagePath, double rescueNetId, double weight, int totalAmount, String? description,@TimestampConverter() List<DateTime> expiringDates, OperationalStatus operationalStatus,@StringConverter() String? manufacturer,@StringConverter() String? brand,@StringConverter() String? type,@StringConverter() String? supplier,@StringConverter() String? website,@StringConverter() String? remarks, int value,@StringConverter() String? sku, String? notes, List<Sign> signs, bool isColdChain
});




}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? imagePath = null,Object? rescueNetId = null,Object? weight = null,Object? totalAmount = null,Object? description = freezed,Object? expiringDates = null,Object? operationalStatus = null,Object? manufacturer = freezed,Object? brand = freezed,Object? type = freezed,Object? supplier = freezed,Object? website = freezed,Object? remarks = freezed,Object? value = null,Object? sku = freezed,Object? notes = freezed,Object? signs = null,Object? isColdChain = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,rescueNetId: null == rescueNetId ? _self.rescueNetId : rescueNetId // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiringDates: null == expiringDates ? _self.expiringDates : expiringDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,operationalStatus: null == operationalStatus ? _self.operationalStatus : operationalStatus // ignore: cast_nullable_to_non_nullable
as OperationalStatus,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,signs: null == signs ? _self.signs : signs // ignore: cast_nullable_to_non_nullable
as List<Sign>,isColdChain: null == isColdChain ? _self.isColdChain : isColdChain // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String imagePath,  double rescueNetId,  double weight,  int totalAmount,  String? description, @TimestampConverter()  List<DateTime> expiringDates,  OperationalStatus operationalStatus, @StringConverter()  String? manufacturer, @StringConverter()  String? brand, @StringConverter()  String? type, @StringConverter()  String? supplier, @StringConverter()  String? website, @StringConverter()  String? remarks,  int value, @StringConverter()  String? sku,  String? notes,  List<Sign> signs,  bool isColdChain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.imagePath,_that.rescueNetId,_that.weight,_that.totalAmount,_that.description,_that.expiringDates,_that.operationalStatus,_that.manufacturer,_that.brand,_that.type,_that.supplier,_that.website,_that.remarks,_that.value,_that.sku,_that.notes,_that.signs,_that.isColdChain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String imagePath,  double rescueNetId,  double weight,  int totalAmount,  String? description, @TimestampConverter()  List<DateTime> expiringDates,  OperationalStatus operationalStatus, @StringConverter()  String? manufacturer, @StringConverter()  String? brand, @StringConverter()  String? type, @StringConverter()  String? supplier, @StringConverter()  String? website, @StringConverter()  String? remarks,  int value, @StringConverter()  String? sku,  String? notes,  List<Sign> signs,  bool isColdChain)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.name,_that.imagePath,_that.rescueNetId,_that.weight,_that.totalAmount,_that.description,_that.expiringDates,_that.operationalStatus,_that.manufacturer,_that.brand,_that.type,_that.supplier,_that.website,_that.remarks,_that.value,_that.sku,_that.notes,_that.signs,_that.isColdChain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String imagePath,  double rescueNetId,  double weight,  int totalAmount,  String? description, @TimestampConverter()  List<DateTime> expiringDates,  OperationalStatus operationalStatus, @StringConverter()  String? manufacturer, @StringConverter()  String? brand, @StringConverter()  String? type, @StringConverter()  String? supplier, @StringConverter()  String? website, @StringConverter()  String? remarks,  int value, @StringConverter()  String? sku,  String? notes,  List<Sign> signs,  bool isColdChain)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.imagePath,_that.rescueNetId,_that.weight,_that.totalAmount,_that.description,_that.expiringDates,_that.operationalStatus,_that.manufacturer,_that.brand,_that.type,_that.supplier,_that.website,_that.remarks,_that.value,_that.sku,_that.notes,_that.signs,_that.isColdChain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item extends Item {
  const _Item({required this.id, this.name, this.imagePath = "", required this.rescueNetId, this.weight = 0.0, required this.totalAmount, this.description, @TimestampConverter() final  List<DateTime> expiringDates = const [], this.operationalStatus = OperationalStatus.deployable, @StringConverter() this.manufacturer, @StringConverter() this.brand, @StringConverter() this.type, @StringConverter() this.supplier, @StringConverter() this.website, @StringConverter() this.remarks, this.value = 0, @StringConverter() this.sku, this.notes, final  List<Sign> signs = const [], this.isColdChain = false}): _expiringDates = expiringDates,_signs = signs,super._();
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  String id;
@override final  String? name;
@override@JsonKey() final  String imagePath;
@override final  double rescueNetId;
@override@JsonKey() final  double weight;
@override final  int totalAmount;
@override final  String? description;
 final  List<DateTime> _expiringDates;
@override@JsonKey()@TimestampConverter() List<DateTime> get expiringDates {
  if (_expiringDates is EqualUnmodifiableListView) return _expiringDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expiringDates);
}

@override@JsonKey() final  OperationalStatus operationalStatus;
@override@StringConverter() final  String? manufacturer;
@override@StringConverter() final  String? brand;
@override@StringConverter() final  String? type;
@override@StringConverter() final  String? supplier;
@override@StringConverter() final  String? website;
@override@StringConverter() final  String? remarks;
@override@JsonKey() final  int value;
@override@StringConverter() final  String? sku;
@override final  String? notes;
 final  List<Sign> _signs;
@override@JsonKey() List<Sign> get signs {
  if (_signs is EqualUnmodifiableListView) return _signs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signs);
}

@override@JsonKey() final  bool isColdChain;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.rescueNetId, rescueNetId) || other.rescueNetId == rescueNetId)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._expiringDates, _expiringDates)&&(identical(other.operationalStatus, operationalStatus) || other.operationalStatus == operationalStatus)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.type, type) || other.type == type)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.website, website) || other.website == website)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.value, value) || other.value == value)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._signs, _signs)&&(identical(other.isColdChain, isColdChain) || other.isColdChain == isColdChain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,imagePath,rescueNetId,weight,totalAmount,description,const DeepCollectionEquality().hash(_expiringDates),operationalStatus,manufacturer,brand,type,supplier,website,remarks,value,sku,notes,const DeepCollectionEquality().hash(_signs),isColdChain]);

@override
String toString() {
  return 'Item(id: $id, name: $name, imagePath: $imagePath, rescueNetId: $rescueNetId, weight: $weight, totalAmount: $totalAmount, description: $description, expiringDates: $expiringDates, operationalStatus: $operationalStatus, manufacturer: $manufacturer, brand: $brand, type: $type, supplier: $supplier, website: $website, remarks: $remarks, value: $value, sku: $sku, notes: $notes, signs: $signs, isColdChain: $isColdChain)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String imagePath, double rescueNetId, double weight, int totalAmount, String? description,@TimestampConverter() List<DateTime> expiringDates, OperationalStatus operationalStatus,@StringConverter() String? manufacturer,@StringConverter() String? brand,@StringConverter() String? type,@StringConverter() String? supplier,@StringConverter() String? website,@StringConverter() String? remarks, int value,@StringConverter() String? sku, String? notes, List<Sign> signs, bool isColdChain
});




}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? imagePath = null,Object? rescueNetId = null,Object? weight = null,Object? totalAmount = null,Object? description = freezed,Object? expiringDates = null,Object? operationalStatus = null,Object? manufacturer = freezed,Object? brand = freezed,Object? type = freezed,Object? supplier = freezed,Object? website = freezed,Object? remarks = freezed,Object? value = null,Object? sku = freezed,Object? notes = freezed,Object? signs = null,Object? isColdChain = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,rescueNetId: null == rescueNetId ? _self.rescueNetId : rescueNetId // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiringDates: null == expiringDates ? _self._expiringDates : expiringDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,operationalStatus: null == operationalStatus ? _self.operationalStatus : operationalStatus // ignore: cast_nullable_to_non_nullable
as OperationalStatus,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,signs: null == signs ? _self._signs : signs // ignore: cast_nullable_to_non_nullable
as List<Sign>,isColdChain: null == isColdChain ? _self.isColdChain : isColdChain // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
