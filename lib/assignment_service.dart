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
    workLogStore?.upsert(_buildEntry(item, containerId, 1));
  }

  _buildEntry(Item item, String containerId, int count) => LogEntry(
      uuid.v4(),
      item.id,
      containerId,
      count,
      DateTime.now(),
      Auth().currentUserName ?? "Unknown");

  Assignment? _find(Item item, String containerId) =>
      store?.all.firstWhereOrNull(
          (a) => a.itemId == item.id && a.containerId == containerId);

  setAmount(Item item, String containerId, int amount) {
    var current = _find(item, containerId);

    if (current != null) {
      store?.upsert(current.copyWith(amount));
      workLogStore
          ?.upsert(_buildEntry(item, containerId, current.count - amount));
    }
  }
}

ChangeNotifierProxyProvider2 provideAssignmentService() =>
    ChangeNotifierProxyProvider2<AssignmentStore, WorkLogStore,
            AssignmentService>(
        create: (ctx) => AssignmentService(),
        update: (ctx, store, workLogStore, service) =>
            service!..update(workLogStore, store));
