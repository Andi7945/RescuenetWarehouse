import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_store.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/container_store.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_container_types.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import "package:collection/collection.dart";

import 'container_dao.dart';
import 'container_visibility_service.dart';
import 'item.dart';
import 'store.dart';

class ContainerService {
  final Store store;
  final ContainerStore containerStore;
  final StoreContainerTypes storeContainerTypes;
  final AssignmentStore assignmentStore;
  final ContainerVisibilityService visibilityService;

  ContainerService(this.store, this.containerStore, this.storeContainerTypes,
      this.assignmentStore, this.visibilityService);

  List<RescueContainer> containers() =>
      containerStore.containers.values.map(fromDao).toList();

  updateContainer(ContainerDao container) {
    containerStore.updateContainer(container);
  }

  Map<RescueContainer, bool> containerWithVisible() =>
      visibilityService.containerVisibility.map((key, value) =>
          MapEntry(fromDao(containerStore.containers[key]!), value));

  RescueContainer fromDao(ContainerDao dao) => RescueContainer.fromDao(
      dao,
      storeContainerTypes.containerTypes
          .firstWhere((type) => type.id == dao.typeId));

  Map<RescueContainer, Map<Item, int>> containerWithItems() {
    return Map.fromEntries(containerStore.containers.values.map((cont) =>
        MapEntry(
            fromDao(cont),
            Map.fromEntries(assignmentStore.assignments
                .where((assignment) => assignment.containerId == cont.id)
                .map((assignment) => MapEntry(
                    store.itemById(assignment.itemId), assignment.count))))));
  }

  Map<Item, int> itemsWithoutContainer() {
    var assignedItems = assignmentStore.assignments
        .groupBy((p0) => p0.itemId)
        .map((key, value) => MapEntry(
            store.itemById(key),
            value.fold(
                0, (previousValue, element) => previousValue + element.count)));

    var map = Map.fromEntries(store.items.map((e) {
      var assigned = assignedItems[e];
      if (assigned == null) {
        return MapEntry(e, e.totalAmount);
      }
      return MapEntry(e, e.totalAmount - assigned);
    }));

    map.removeWhere((key, value) => value == 0);

    return map;
  }

  Map<RescueContainer, int> assignmentsFor(Item item) {
    return assignmentStore.assignments
        .where((a) => a.itemId == item.id)
        .groupBy((p0) => fromDao(containerStore.containers[p0.containerId]!))
        .mapValues((value) => value.fold(0, (prev, curr) => prev + curr.count));
  }

  List<RescueContainer> get containerValues =>
      containerStore.containerValues.map(fromDao).toList();

  List<String> otherContainerOptions(Item item) {
    return containerValues
        .where((element) => !assignmentStore.assignments
            .any((a) => a.containerId == element.id && a.itemId == item.id))
        .map((e) => e.name)
        .whereNotNull()
        .toList();
  }
}

ProxyProvider5 proxyContainerService() => ProxyProvider5<
        Store,
        ContainerStore,
        StoreContainerTypes,
        AssignmentStore,
        ContainerVisibilityService,
        ContainerService>(
    update: (ctx, store, containerStore, storeContainerTypes, assignmentStore,
            visibilityService, prev) =>
        ContainerService(store, containerStore, storeContainerTypes,
            assignmentStore, visibilityService));
