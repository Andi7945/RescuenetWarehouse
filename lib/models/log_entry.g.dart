// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => _LogEntry(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  containerId: json['containerId'] as String,
  count: (json['count'] as num).toInt(),
  date: const TimestampConverter().fromJson(json['date'] as Timestamp),
  user: json['user'] as String,
);

Map<String, dynamic> _$LogEntryToJson(_LogEntry instance) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'containerId': instance.containerId,
  'count': instance.count,
  'date': const TimestampConverter().toJson(instance.date),
  'user': instance.user,
};
