// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignImpl _$$SignImplFromJson(Map<String, dynamic> json) => _$SignImpl(
      id: json['id'] as String,
      unNumber: json['unNumber'] as String?,
      imagePath: json['imagePath'] as String?,
      instructions: json['instructions'] as String?,
      remarks: json['remarks'] as String?,
      sdsPath: (json['sdsPath'] as List<dynamic>?)
              ?.map((e) => FirebaseDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dangerType: json['dangerType'] as String?,
      properShippingName: json['properShippingName'] as String?,
      maxWeightPAX: (json['maxWeightPAX'] as num?)?.toDouble() ?? 0.0,
      maxWeightCargo: (json['maxWeightCargo'] as num?)?.toDouble() ?? 0.0,
      otherDocuments: (json['otherDocuments'] as List<dynamic>?)
              ?.map((e) => FirebaseDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SignImplToJson(_$SignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unNumber': instance.unNumber,
      'imagePath': instance.imagePath,
      'instructions': instance.instructions,
      'remarks': instance.remarks,
      'sdsPath': instance.sdsPath.map((e) => e.toJson()).toList(),
      'dangerType': instance.dangerType,
      'properShippingName': instance.properShippingName,
      'maxWeightPAX': instance.maxWeightPAX,
      'maxWeightCargo': instance.maxWeightCargo,
      'otherDocuments': instance.otherDocuments.map((e) => e.toJson()).toList(),
    };
