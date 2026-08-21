// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModuleDestination _$ModuleDestinationFromJson(Map<String, dynamic> json) =>
    _ModuleDestination(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: (json['priority'] as num?)?.toInt(),
      badgeShape: $enumDecodeNullable(
        _$PriorityBadgeShapeEnumMap,
        json['badgeShape'],
      ),
    );

Map<String, dynamic> _$ModuleDestinationToJson(_ModuleDestination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priority': instance.priority,
      'badgeShape': _$PriorityBadgeShapeEnumMap[instance.badgeShape],
    };

const _$PriorityBadgeShapeEnumMap = {
  PriorityBadgeShape.circle: 'circle',
  PriorityBadgeShape.rectangle: 'rectangle',
  PriorityBadgeShape.triangle: 'triangle',
  PriorityBadgeShape.diamond: 'diamond',
  PriorityBadgeShape.star: 'star',
  PriorityBadgeShape.heart: 'heart',
  PriorityBadgeShape.cross: 'cross',
};
