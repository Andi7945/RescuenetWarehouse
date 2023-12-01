// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogEntryImpl _$$LogEntryImplFromJson(Map<String, dynamic> json) =>
    _$LogEntryImpl(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      containerId: json['containerId'] as String,
      count: json['count'] as int,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      user: json['user'] as String,
    );

Map<String, dynamic> _$$LogEntryImplToJson(_$LogEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'containerId': instance.containerId,
      'count': instance.count,
      'date': const TimestampConverter().toJson(instance.date),
      'user': instance.user,
    };
