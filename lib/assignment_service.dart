import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_store.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

import 'assignment.dart';
import 'container_dao.dart';
import 'item.dart';
import 'store.dart';

class AssignmentService extends ChangeNotifier {
  List<ContainerDao> knownContainerValues = [];
  WorkLogStore? workLogStore;
  AssignmentStore? store;

  update(Store mainStore, WorkLogStore workLogStore, AssignmentStore store) {
    knownContainerValues = mainStore.containerValues;
    this.workLogStore = workLogStore;
    this.store = store;
  }

  addContainer(String containerName, Item item) {
    var container = knownContainerValues
        .firstWhere((element) => element.name == containerName);
    var assignment = Assignment(item.id, container.id, 1);

    if (store?.add(assignment) ?? false) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }

  increase(Item item, String containerId) {
    var assignment = Assignment(item.id, containerId, 1);
    if (store?.increase(assignment) ?? false) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }

  reduce(Item item, String containerId) {
    var assignment = Assignment(item.id, containerId, 1);
    if (store?.reduce(assignment) ?? false) {
      workLogStore?.add(assignment);
      notifyListeners();
    }
  }
}

ChangeNotifierProxyProvider3 provideAssignmentService() =>
    ChangeNotifierProxyProvider3<AssignmentStore, WorkLogStore, Store,
            AssignmentService>(
        create: (ctx) => AssignmentService(),
        update: (ctx, store, workLogStore, mainStore, service) =>
            service!..update(mainStore, workLogStore, store));
