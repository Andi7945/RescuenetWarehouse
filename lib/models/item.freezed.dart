// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Item _$ItemFromJson(Map<String, dynamic> json) {
  return _Item.fromJson(json);
}

/// @nodoc
mixin _$Item {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  double get rescueNetId => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get totalAmount => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @TimestampConverter()
  List<DateTime> get expiringDates => throw _privateConstructorUsedError;
  OperationalStatus get operationalStatus => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get supplier => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get remarks => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<Sign> get signs => throw _privateConstructorUsedError;
  bool get isColdChain => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemCopyWith<Item> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemCopyWith<$Res> {
  factory $ItemCopyWith(Item value, $Res Function(Item) then) =
      _$ItemCopyWithImpl<$Res, Item>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String imagePath,
      double rescueNetId,
      double weight,
      int totalAmount,
      String? description,
      @TimestampConverter() List<DateTime> expiringDates,
      OperationalStatus operationalStatus,
      String? manufacturer,
      String? brand,
      String? type,
      String? supplier,
      String? website,
      String? remarks,
      int value,
      String? sku,
      String? notes,
      List<Sign> signs,
      bool isColdChain});
}

/// @nodoc
class _$ItemCopyWithImpl<$Res, $Val extends Item>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? imagePath = null,
    Object? rescueNetId = null,
    Object? weight = null,
    Object? totalAmount = null,
    Object? description = freezed,
    Object? expiringDates = null,
    Object? operationalStatus = null,
    Object? manufacturer = freezed,
    Object? brand = freezed,
    Object? type = freezed,
    Object? supplier = freezed,
    Object? website = freezed,
    Object? remarks = freezed,
    Object? value = null,
    Object? sku = freezed,
    Object? notes = freezed,
    Object? signs = null,
    Object? isColdChain = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      rescueNetId: null == rescueNetId
          ? _value.rescueNetId
          : rescueNetId // ignore: cast_nullable_to_non_nullable
              as double,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      expiringDates: null == expiringDates
          ? _value.expiringDates
          : expiringDates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      operationalStatus: null == operationalStatus
          ? _value.operationalStatus
          : operationalStatus // ignore: cast_nullable_to_non_nullable
              as OperationalStatus,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      supplier: freezed == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      signs: null == signs
          ? _value.signs
          : signs // ignore: cast_nullable_to_non_nullable
              as List<Sign>,
      isColdChain: null == isColdChain
          ? _value.isColdChain
          : isColdChain // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemImplCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$$ItemImplCopyWith(
          _$ItemImpl value, $Res Function(_$ItemImpl) then) =
      __$$ItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String imagePath,
      double rescueNetId,
      double weight,
      int totalAmount,
      String? description,
      @TimestampConverter() List<DateTime> expiringDates,
      OperationalStatus operationalStatus,
      String? manufacturer,
      String? brand,
      String? type,
      String? supplier,
      String? website,
      String? remarks,
      int value,
      String? sku,
      String? notes,
      List<Sign> signs,
      bool isColdChain});
}

/// @nodoc
class __$$ItemImplCopyWithImpl<$Res>
    extends _$ItemCopyWithImpl<$Res, _$ItemImpl>
    implements _$$ItemImplCopyWith<$Res> {
  __$$ItemImplCopyWithImpl(_$ItemImpl _value, $Res Function(_$ItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? imagePath = null,
    Object? rescueNetId = null,
    Object? weight = null,
    Object? totalAmount = null,
    Object? description = freezed,
    Object? expiringDates = null,
    Object? operationalStatus = null,
    Object? manufacturer = freezed,
    Object? brand = freezed,
    Object? type = freezed,
    Object? supplier = freezed,
    Object? website = freezed,
    Object? remarks = freezed,
    Object? value = null,
    Object? sku = freezed,
    Object? notes = freezed,
    Object? signs = null,
    Object? isColdChain = null,
  }) {
    return _then(_$ItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      rescueNetId: null == rescueNetId
          ? _value.rescueNetId
          : rescueNetId // ignore: cast_nullable_to_non_nullable
              as double,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      expiringDates: null == expiringDates
          ? _value._expiringDates
          : expiringDates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      operationalStatus: null == operationalStatus
          ? _value.operationalStatus
          : operationalStatus // ignore: cast_nullable_to_non_nullable
              as OperationalStatus,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      supplier: freezed == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      signs: null == signs
          ? _value._signs
          : signs // ignore: cast_nullable_to_non_nullable
              as List<Sign>,
      isColdChain: null == isColdChain
          ? _value.isColdChain
          : isColdChain // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemImpl implements _Item {
  const _$ItemImpl(
      {required this.id,
      this.name,
      this.imagePath = "https://via.placeholder.com/90x81",
      required this.rescueNetId,
      this.weight = 0.0,
      required this.totalAmount,
      this.description,
      @TimestampConverter() final List<DateTime> expiringDates = const [],
      this.operationalStatus = OperationalStatus.deployable,
      this.manufacturer,
      this.brand,
      this.type,
      this.supplier,
      this.website,
      this.remarks,
      this.value = 0,
      this.sku,
      this.notes,
      final List<Sign> signs = const [],
      this.isColdChain = false})
      : _expiringDates = expiringDates,
        _signs = signs;

  factory _$ItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  @JsonKey()
  final String imagePath;
  @override
  final double rescueNetId;
  @override
  @JsonKey()
  final double weight;
  @override
  final int totalAmount;
  @override
  final String? description;
  final List<DateTime> _expiringDates;
  @override
  @JsonKey()
  @TimestampConverter()
  List<DateTime> get expiringDates {
    if (_expiringDates is EqualUnmodifiableListView) return _expiringDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expiringDates);
  }

  @override
  @JsonKey()
  final OperationalStatus operationalStatus;
  @override
  final String? manufacturer;
  @override
  final String? brand;
  @override
  final String? type;
  @override
  final String? supplier;
  @override
  final String? website;
  @override
  final String? remarks;
  @override
  @JsonKey()
  final int value;
  @override
  final String? sku;
  @override
  final String? notes;
  final List<Sign> _signs;
  @override
  @JsonKey()
  List<Sign> get signs {
    if (_signs is EqualUnmodifiableListView) return _signs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_signs);
  }

  @override
  @JsonKey()
  final bool isColdChain;

  @override
  String toString() {
    return 'Item(id: $id, name: $name, imagePath: $imagePath, rescueNetId: $rescueNetId, weight: $weight, totalAmount: $totalAmount, description: $description, expiringDates: $expiringDates, operationalStatus: $operationalStatus, manufacturer: $manufacturer, brand: $brand, type: $type, supplier: $supplier, website: $website, remarks: $remarks, value: $value, sku: $sku, notes: $notes, signs: $signs, isColdChain: $isColdChain)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.rescueNetId, rescueNetId) ||
                other.rescueNetId == rescueNetId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._expiringDates, _expiringDates) &&
            (identical(other.operationalStatus, operationalStatus) ||
                other.operationalStatus == operationalStatus) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._signs, _signs) &&
            (identical(other.isColdChain, isColdChain) ||
                other.isColdChain == isColdChain));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        imagePath,
        rescueNetId,
        weight,
        totalAmount,
        description,
        const DeepCollectionEquality().hash(_expiringDates),
        operationalStatus,
        manufacturer,
        brand,
        type,
        supplier,
        website,
        remarks,
        value,
        sku,
        notes,
        const DeepCollectionEquality().hash(_signs),
        isColdChain
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      __$$ItemImplCopyWithImpl<_$ItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemImplToJson(
      this,
    );
  }
}

abstract class _Item implements Item {
  const factory _Item(
      {required final String id,
      final String? name,
      final String imagePath,
      required final double rescueNetId,
      final double weight,
      required final int totalAmount,
      final String? description,
      @TimestampConverter() final List<DateTime> expiringDates,
      final OperationalStatus operationalStatus,
      final String? manufacturer,
      final String? brand,
      final String? type,
      final String? supplier,
      final String? website,
      final String? remarks,
      final int value,
      final String? sku,
      final String? notes,
      final List<Sign> signs,
      final bool isColdChain}) = _$ItemImpl;

  factory _Item.fromJson(Map<String, dynamic> json) = _$ItemImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String get imagePath;
  @override
  double get rescueNetId;
  @override
  double get weight;
  @override
  int get totalAmount;
  @override
  String? get description;
  @override
  @TimestampConverter()
  List<DateTime> get expiringDates;
  @override
  OperationalStatus get operationalStatus;
  @override
  String? get manufacturer;
  @override
  String? get brand;
  @override
  String? get type;
  @override
  String? get supplier;
  @override
  String? get website;
  @override
  String? get remarks;
  @override
  int get value;
  @override
  String? get sku;
  @override
  String? get notes;
  @override
  List<Sign> get signs;
  @override
  bool get isColdChain;
  @override
  @JsonKey(ignore: true)
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
