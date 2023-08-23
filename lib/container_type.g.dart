// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerType _$ContainerTypeFromJson(Map<String, dynamic> json) =>
    ContainerType(
      json['id'] as String,
      json['name'] as String,
      json['imagePath'] as String?,
      (json['emptyWeight'] as num).toDouble(),
      json['measurements'] as String,
    );

Map<String, dynamic> _$ContainerTypeToJson(ContainerType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imagePath': instance.imagePath,
      'emptyWeight': instance.emptyWeight,
      'measurements': instance.measurements,
    };
