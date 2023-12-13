// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      imagePath:
          json['imagePath'] as String? ?? "https://via.placeholder.com/90x81",
      rescueNetId: (json['rescueNetId'] as num).toDouble(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount'] as int,
      description: json['description'] as String?,
      expiringDates: (json['expiringDates'] as List<dynamic>?)
              ?.map((e) => const TimestampConverter().fromJson(e as Timestamp))
              .toList() ??
          const [],
      operationalStatus: $enumDecodeNullable(
              _$OperationalStatusEnumMap, json['operationalStatus']) ??
          OperationalStatus.deployable,
      manufacturer: json['manufacturer'] as String?,
      brand: json['brand'] as String?,
      type: json['type'] as String?,
      supplier: json['supplier'] as String?,
      website: json['website'] as String?,
      remarks: json['remarks'] as String?,
      value: json['value'] as int? ?? 0,
      sku: json['sku'] as String?,
      notes: json['notes'] as String?,
      signs: (json['signs'] as List<dynamic>?)
              ?.map((e) => Sign.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isColdChain: json['isColdChain'] as bool? ?? false,
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
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
      'operationalStatus':
          _$OperationalStatusEnumMap[instance.operationalStatus]!,
      'manufacturer': instance.manufacturer,
      'brand': instance.brand,
      'type': instance.type,
      'supplier': instance.supplier,
      'website': instance.website,
      'remarks': instance.remarks,
      'value': instance.value,
      'sku': instance.sku,
      'notes': instance.notes,
      'signs': instance.signs.map((e) => e.toJson()).toList(),
      'isColdChain': instance.isColdChain,
    };

const _$OperationalStatusEnumMap = {
  OperationalStatus.deployable: 'deployable',
  OperationalStatus.needsRepair: 'needsRepair',
  OperationalStatus.toBeReplaced: 'toBeReplaced',
};
