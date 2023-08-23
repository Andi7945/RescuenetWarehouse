// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      json['id'] as String,
      json['totalAmount'] as int,
      (json['rescueNetId'] as num).toDouble(),
    )
      ..name = json['name'] as String?
      ..imagePath = json['imagePath'] as String
      ..weight = (json['weight'] as num).toDouble()
      ..description = json['description'] as String?
      ..expiringDates = (json['expiringDates'] as List<dynamic>)
          .map((e) => const TimestampConverter().fromJson(e as Timestamp))
          .toList()
      ..operationalStatus =
          $enumDecode(_$OperationalStatusEnumMap, json['operationalStatus'])
      ..manufacturer = json['manufacturer'] as String?
      ..brand = json['brand'] as String?
      ..type = json['type'] as String?
      ..supplier = json['supplier'] as String?
      ..website = json['website'] as String?
      ..remarks = json['remarks'] as String?
      ..value = json['value'] as int
      ..sku = json['sku'] as String?
      ..notes = json['notes'] as String?
      ..signs = (json['signs'] as List<dynamic>?)
              ?.map((e) => Sign.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..isColdChain = json['isColdChain'] as bool;

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
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
      'signs': instance.signs,
      'isColdChain': instance.isColdChain,
    };

const _$OperationalStatusEnumMap = {
  OperationalStatus.deployable: 'deployable',
  OperationalStatus.needsRepair: 'needsRepair',
  OperationalStatus.toBeReplaced: 'toBeReplaced',
};
