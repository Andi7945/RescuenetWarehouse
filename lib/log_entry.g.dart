// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
      json['id'] as String,
      Assignment.fromJson(json['assignment'] as Map<String, dynamic>),
      DateTime.parse(json['date'] as String),
      json['user'] as String,
    );

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
      'id': instance.id,
      'assignment': instance.assignment,
      'date': instance.date.toIso8601String(),
      'user': instance.user,
    };
