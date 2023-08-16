import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_store.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

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
    var assignment = Assignment(item.id, container.id, 1);

    if (store?.add(assignment) ?? false) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }

  increase(Item item, double containerId) {
    var assignment = Assignment(item.id, containerId, 1);
    if (store?.increase(assignment) ?? false) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }

  reduce(Item item, double containerId) {
    var assignment = Assignment(item.id, containerId, -1);
    if (store?.reduce(assignment) ?? false) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }
}

ChangeNotifierProxyProvider3 provideAssignmentService() =>
    ChangeNotifierProxyProvider3<AssignmentStore, WorkLogStore, ContainerStore,
            AssignmentService>(
        create: (ctx) => AssignmentService(),
        update: (ctx, store, workLogStore, containerStore, service) =>
            service!..update(containerStore, workLogStore, store));
