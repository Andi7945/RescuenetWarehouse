// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
      json['id'] as String,
      json['itemId'] as String,
      json['containerId'] as String,
      json['count'] as int,
      const TimestampConverter().fromJson(json['date'] as Timestamp),
      json['user'] as String,
    );

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'containerId': instance.containerId,
      'count': instance.count,
      'date': const TimestampConverter().toJson(instance.date),
      'user': instance.user,
    };
