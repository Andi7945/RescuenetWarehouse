// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Assignment _$AssignmentFromJson(Map<String, dynamic> json) => Assignment(
      json['id'] as String,
      json['itemId'] as String,
      (json['containerId'] as num).toDouble(),
      json['count'] as int,
    );

Map<String, dynamic> _$AssignmentToJson(Assignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'containerId': instance.containerId,
      'count': instance.count,
    };
