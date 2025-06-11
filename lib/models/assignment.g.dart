// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Assignment _$AssignmentFromJson(Map<String, dynamic> json) => _Assignment(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  containerId: json['containerId'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$AssignmentToJson(_Assignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'containerId': instance.containerId,
      'count': instance.count,
    };
