import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

import 'collection_extensions.dart';

import 'stores.dart';

import 'assignment.dart';
import 'container_dao.dart';
import 'container_store.dart';
import 'item.dart';

class AssignmentService extends ChangeNotifier {
  List<ContainerDao> knownContainerValues = [];
  WorkLogStore? workLogStore;
  AssignmentStore? store;

  update(ContainerStore containerStore, WorkLogStore workLogStore,
      AssignmentStore store) {
    knownContainerValues = containerStore.containerValues;
    this.workLogStore = workLogStore;
    this.store = store;
  }

  addContainer(double containerId, Item item) {
    var container =
        knownContainerValues.firstWhere((element) => element.id == containerId);
    var assignment = Assignment(uuid.v4(), item.id, container.id, 1);

    store?.upsert(assignment);
    workLogStore?.add(assignment);
  }

  increase(Item item, double containerId) {
    var assignment = Assignment(uuid.v4(), item.id, containerId, 1);
    if (_change(assignment, 1)) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }

  reduce(Item item, double containerId) {
    var assignment = Assignment(uuid.v4(), item.id, containerId, -1);
    if (_change(assignment, -1)) {
      workLogStore?.add(assignment);
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

ChangeNotifierProxyProvider3 provideAssignmentService() =>
    ChangeNotifierProxyProvider3<AssignmentStore, WorkLogStore, ContainerStore,
            AssignmentService>(
        create: (ctx) => AssignmentService(),
        update: (ctx, store, workLogStore, containerStore, service) =>
            service!..update(containerStore, workLogStore, store));
