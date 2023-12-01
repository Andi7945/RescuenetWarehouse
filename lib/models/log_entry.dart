import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/models/json_converter_timestamp.dart';

part 'log_entry.freezed.dart';

part 'log_entry.g.dart';

@freezed
class LogEntry extends FirebaseStorable<LogEntry> with _$LogEntry {
  const factory LogEntry({
    required String id,
    required String itemId,
    required String containerId,
    required int count,
    @TimestampConverter() required DateTime date,
    required String user,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);
}
