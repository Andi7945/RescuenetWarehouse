// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sign _$SignFromJson(Map<String, dynamic> json) => Sign(
      json['id'] as String,
    )
      ..unNumber = json['unNumber'] as String?
      ..imagePath = json['imagePath'] as String?
      ..instructions = json['instructions'] as String?
      ..remarks = json['remarks'] as String?
      ..sdsPath = (json['sdsPath'] as List<dynamic>?)
              ?.map((e) => const FirebaseDocumentConverter()
                  .fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..dangerType = json['dangerType'] as String?
      ..properShippingName = json['properShippingName'] as String?
      ..maxWeightPAX = (json['maxWeightPAX'] as num).toDouble()
      ..maxWeightCargo = (json['maxWeightCargo'] as num).toDouble()
      ..otherDocuments = (json['otherDocuments'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

Map<String, dynamic> _$SignToJson(Sign instance) => <String, dynamic>{
      'id': instance.id,
      'unNumber': instance.unNumber,
      'imagePath': instance.imagePath,
      'instructions': instance.instructions,
      'remarks': instance.remarks,
      'sdsPath': instance.sdsPath
          ?.map(const FirebaseDocumentConverter().toJson)
          .toList(),
      'dangerType': instance.dangerType,
      'properShippingName': instance.properShippingName,
      'maxWeightPAX': instance.maxWeightPAX,
      'maxWeightCargo': instance.maxWeightCargo,
      'otherDocuments': instance.otherDocuments,
    };
