import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

import 'assignment.dart';

part 'log_entry.g.dart';

@JsonSerializable()
class LogEntry extends FirebaseStorable<LogEntry> {
  @override
  final String id;
  final Assignment assignment;
  final DateTime date;
  final String user;

  LogEntry(this.id, this.assignment, this.date, this.user);

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);
}
