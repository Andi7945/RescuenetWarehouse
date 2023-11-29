// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerDaoImpl _$$ContainerDaoImplFromJson(Map<String, dynamic> json) =>
    _$ContainerDaoImpl(
      id: json['id'] as String,
      number: json['number'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      typeId: json['typeId'] as String?,
      sequentialBuild:
          $enumDecode(_$SequentialBuildEnumMap, json['sequentialBuild']),
      moduleDestinationId: json['moduleDestinationId'] as String?,
      currentLocationId: json['currentLocationId'] as String?,
      isReady: json['isReady'] as bool,
      toDeploy: json['toDeploy'] as bool,
    );

Map<String, dynamic> _$$ContainerDaoImplToJson(_$ContainerDaoImpl instance) =>
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
