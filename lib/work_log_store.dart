import 'dart:collection';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/assignment.dart';

import 'log_entry.dart';

import 'package:intl/intl.dart';

import 'utils/auth_util.dart';

class WorkLogStore extends ChangeNotifier {
  final DateFormat formatter = DateFormat('MMM d, yyyy');
  final List<LogEntry> _logEntries = [
    LogEntry(Assignment("2", 1, 2), DateTime(2023, 6, 28), "Andi"),
    LogEntry(Assignment("1", 1, -1), DateTime(2023, 6, 28), "Gert Jan"),
    LogEntry(Assignment("1", 3, -1), DateTime(2023, 6, 28), "Gert Jan"),
    LogEntry(Assignment("6", 3, 200), DateTime(2023, 6, 28), "Michael"),
    LogEntry(Assignment("1", 3, 2), DateTime(2023, 6, 28), "Michael"),
    LogEntry(Assignment("2", 1, -1), DateTime(2023, 6, 26), "Andi"),
    LogEntry(Assignment("1", 1, -1), DateTime(2023, 6, 26), "Gert Jan"),
  ];

  UnmodifiableListView<LogEntry> get entries =>
      UnmodifiableListView(_logEntries);

  add(Assignment assignment) {
    _logEntries.add(LogEntry(assignment, DateTime.now(),
        Auth().currentUser?.displayName ?? "Unknown"));
  }
}
