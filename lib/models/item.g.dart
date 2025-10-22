// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: json['id'] as String,
  name: json['name'] as String?,
  imagePath: json['imagePath'] as String? ?? "",
  rescueNetId: (json['rescueNetId'] as num).toDouble(),
  weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
  totalAmount: (json['totalAmount'] as num).toInt(),
  description: json['description'] as String?,
  expiringDates:
      (json['expiringDates'] as List<dynamic>?)
          ?.map((e) => const TimestampConverter().fromJson(e as Timestamp))
          .toList() ??
      const [],
  operationalStatus:
      $enumDecodeNullable(
        _$OperationalStatusEnumMap,
        json['operationalStatus'],
      ) ??
      OperationalStatus.deployable,
  manufacturer: const StringConverter().fromJson(json['manufacturer']),
  brand: const StringConverter().fromJson(json['brand']),
  type: const StringConverter().fromJson(json['type']),
  supplier: const StringConverter().fromJson(json['supplier']),
  website: const StringConverter().fromJson(json['website']),
  remarks: const StringConverter().fromJson(json['remarks']),
  value: (json['value'] as num?)?.toInt() ?? 0,
  sku: const StringConverter().fromJson(json['sku']),
  notes: json['notes'] as String?,
  signs:
      (json['signs'] as List<dynamic>?)
          ?.map((e) => Sign.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isColdChain: json['isColdChain'] as bool? ?? false,
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imagePath': instance.imagePath,
  'rescueNetId': instance.rescueNetId,
  'weight': instance.weight,
  'totalAmount': instance.totalAmount,
  'description': instance.description,
  'expiringDates': instance.expiringDates
      .map(const TimestampConverter().toJson)
      .toList(),
  'operationalStatus': _$OperationalStatusEnumMap[instance.operationalStatus]!,
  'manufacturer': const StringConverter().toJson(instance.manufacturer),
  'brand': const StringConverter().toJson(instance.brand),
  'type': const StringConverter().toJson(instance.type),
  'supplier': const StringConverter().toJson(instance.supplier),
  'website': const StringConverter().toJson(instance.website),
  'remarks': const StringConverter().toJson(instance.remarks),
  'value': instance.value,
  'sku': const StringConverter().toJson(instance.sku),
  'notes': instance.notes,
  'signs': instance.signs.map((e) => e.toJson()).toList(),
  'isColdChain': instance.isColdChain,
};

const _$OperationalStatusEnumMap = {
  OperationalStatus.deployable: 'deployable',
  OperationalStatus.needsRepair: 'needsRepair',
  OperationalStatus.toBeReplaced: 'toBeReplaced',
};
