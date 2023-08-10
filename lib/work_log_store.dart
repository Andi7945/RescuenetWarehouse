import 'dart:collection';
import "package:collection/collection.dart";

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/assignment.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';

import 'log_entry.dart';

import 'package:intl/intl.dart';

import 'utils/auth_util.dart';

class WorkLogStore extends ChangeNotifier {
  final DateFormat formatter = DateFormat('MMM d, yyyy');
  final List<LogEntry> _logEntries = [];

  UnmodifiableMapView<String, Map<ItemAndContainer, CountAndUser>>
      get logEntries {
    var groupedEntries = groupBy(_logEntries, (p0) => formatter.format(p0.date))
        .mapValues(_expandAndSum);
    return UnmodifiableMapView(groupedEntries);
  }

  Map<ItemAndContainer, CountAndUser> _expandAndSum(List<LogEntry> entries) {
    return entries
        .groupBy((p0) =>
            ItemAndContainer(p0.assignment.itemId, p0.assignment.containerId))
        .mapValues((value) => value.fold(
            CountAndUser("", 0),
            (previousValue, element) => CountAndUser(
                {previousValue.user, element.user}
                    .whereNot((element) => element == "")
                    .join(","),
                previousValue.count + element.assignment.count)));
  }

  add(Assignment assignment) {
    _logEntries.add(LogEntry(assignment, DateTime.now(),
        Auth().currentUser?.displayName ?? "NO_NAME"));
  }
}

class ItemAndContainer extends Equatable {
  final String itemId;
  final String containerId;

  ItemAndContainer(this.itemId, this.containerId);

  @override
  List<Object> get props => [itemId, containerId];
}

class CountAndUser extends Equatable {
  final String user;
  final int count;

  CountAndUser(this.user, this.count);

  @override
  List<Object> get props => [user, count];
}
