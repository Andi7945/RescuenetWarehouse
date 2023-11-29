// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerTypeImpl _$$ContainerTypeImplFromJson(Map<String, dynamic> json) =>
    _$ContainerTypeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String?,
      emptyWeight: (json['emptyWeight'] as num).toDouble(),
      measurements: json['measurements'] as String,
    );

Map<String, dynamic> _$$ContainerTypeImplToJson(_$ContainerTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imagePath': instance.imagePath,
      'emptyWeight': instance.emptyWeight,
      'measurements': instance.measurements,
    };
