import 'dart:collection';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';

import 'assignment.dart';
import 'data_mocks.dart';

class AssignmentStore extends ChangeNotifier {
  final List<Assignment> _assignments = [
    // assignment_item1_container1,
    // assignment_item1_container3
  ];

  UnmodifiableListView<Assignment> get assignments =>
      UnmodifiableListView(_assignments);

  bool add(Assignment assignment) {
    if (_assignments.none(_matchesIds(assignment))) {
      _assignments.add(assignment);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool increase(Assignment assignment) => _change(assignment, 1);

  bool reduce(Assignment assignment) => _change(assignment, -1);

  bool _change(Assignment assignment, int amount) {
    var current = _assignments.firstWhereOrNull(_matchesIds(assignment));
    if (current != null) {
      current.count += amount;
      _assignments.removeWhere((element) => element.count == 0);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool Function(Assignment a) _matchesIds(Assignment assignment) =>
      (a) => (a.itemId == assignment.itemId &&
          a.containerId == assignment.containerId);
}
