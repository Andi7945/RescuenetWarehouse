// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerDao _$ContainerDaoFromJson(Map<String, dynamic> json) => ContainerDao(
      json['id'] as String,
      json['number'] as int,
      json['name'] as String,
      json['description'] as String?,
      json['typeId'] as String?,
      $enumDecode(_$SequentialBuildEnumMap, json['sequentialBuild']),
      json['moduleDestinationId'] as String?,
      json['currentLocationId'] as String?,
      json['isReady'] as bool,
      json['toDeploy'] as bool,
    );

Map<String, dynamic> _$ContainerDaoToJson(ContainerDao instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'name': instance.name,
      'description': instance.description,
      'typeId': instance.typeId,
      'sequentialBuild': _$SequentialBuildEnumMap[instance.sequentialBuild]!,
      'moduleDestinationId': instance.moduleDestinationId,
      'currentLocationId': instance.currentLocationId,
      'isReady': instance.isReady,
      'toDeploy': instance.toDeploy,
    };

const _$SequentialBuildEnumMap = {
  SequentialBuild.preBuild: 'preBuild',
  SequentialBuild.firstBuild: 'firstBuild',
  SequentialBuild.laterBuild: 'laterBuild',
  SequentialBuild.supplies: 'supplies',
};
