import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/main.dart';

import 'collection_extensions.dart';

import 'log_entry.dart';
import 'stores.dart';

import 'assignment.dart';
import 'item.dart';
import 'utils/auth_util.dart';

class AssignmentService extends ChangeNotifier {
  WorkLogStore? workLogStore;
  AssignmentStore? store;

  update(WorkLogStore workLogStore, AssignmentStore store) {
    this.workLogStore = workLogStore;
    this.store = store;
  }

  addContainer(String containerId, Item item) {
    var assignment = Assignment(uuid.v4(), item.id, containerId, 1);

    store?.upsert(assignment);
    workLogStore?.upsert(_buildEntry(assignment));
  }

  _buildEntry(Assignment assignment) => LogEntry(uuid.v4(), assignment,
      DateTime.now(), Auth().currentUser?.displayName ?? "Unknown");

  increase(Item item, String containerId) {
    var assignment = Assignment(uuid.v4(), item.id, containerId, 1);
    if (_change(assignment, 1)) {
      workLogStore?.upsert(_buildEntry(assignment));
      notifyListeners();
    }
  }

  reduce(Item item, String containerId) {
    var assignment = Assignment(uuid.v4(), item.id, containerId, -1);
    if (_change(assignment, -1)) {
      workLogStore?.upsert(_buildEntry(assignment));
      notifyListeners();
    }
  }

  bool _change(Assignment assignment, int amount) {
    var current = store?.all.firstWhereOrNull(_matchesIds(assignment));
    if (current != null) {
      current.count += amount;
      store?.all.removeWhere((element) => element.count == 0);
      return true;
    }
    return false;
  }

  bool Function(Assignment a) _matchesIds(Assignment assignment) =>
      (a) => (a.itemId == assignment.itemId &&
          a.containerId == assignment.containerId);
}

ChangeNotifierProxyProvider2 provideAssignmentService() =>
    ChangeNotifierProxyProvider2<AssignmentStore, WorkLogStore,
            AssignmentService>(
        create: (ctx) => AssignmentService(),
        update: (ctx, store, workLogStore, service) =>
            service!..update(workLogStore, store));
