import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/json_converter_timestamp.dart';

part 'log_entry.g.dart';

@JsonSerializable()
class LogEntry extends FirebaseStorable<LogEntry> {
  @override
  final String id;
  final String itemId;
  final String containerId;
  final int count;
  @TimestampConverter()
  final DateTime date;
  final String user;

  LogEntry(
      this.id, this.itemId, this.containerId, this.count, this.date, this.user);

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);
}
