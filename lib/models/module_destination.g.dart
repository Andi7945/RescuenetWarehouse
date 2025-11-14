// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModuleDestination _$ModuleDestinationFromJson(Map<String, dynamic> json) =>
    _ModuleDestination(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ModuleDestinationToJson(_ModuleDestination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priority': instance.priority,
    };
