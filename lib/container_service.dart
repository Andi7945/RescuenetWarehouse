import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_store.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/container_mapper_service.dart';
import 'package:rescuenet_warehouse/container_store.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'container_dao.dart';
import 'container_visibility_service.dart';
import 'item.dart';
import 'item_service.dart';

class ContainerService {
  final ItemService itemService;
  final ContainerStore containerStore;
  final ContainerMapperService containerMapperService;
  final AssignmentStore assignmentStore;
  final ContainerVisibilityService visibilityService;

  ContainerService(
      this.itemService,
      this.containerStore,
      this.containerMapperService,
      this.assignmentStore,
      this.visibilityService);

  List<RescueContainer> containers() => containerStore.containers.values
      .map(containerMapperService.fromDao)
      .toList();

  updateContainer(ContainerDao container) {
    containerStore.updateContainer(container);
  }

  Map<RescueContainer, Map<Item, int>> containerWithItems() {
    return Map.fromEntries(containerStore.containers.values.map((cont) =>
        MapEntry(
            containerMapperService.fromDao(cont),
            Map.fromEntries(assignmentStore.assignments
                .where((assignment) => assignment.containerId == cont.id)
                .map((assignment) => MapEntry(
                    itemService.itemById(assignment.itemId),
                    assignment.count))))));
  }

  Map<Item, int> itemsWithoutContainer() {
    var assignedItems = assignmentStore.assignments
        .groupBy((p0) => p0.itemId)
        .map((key, value) => MapEntry(
            itemService.itemById(key),
            value.fold(
                0, (previousValue, element) => previousValue + element.count)));

    var map = Map.fromEntries(itemService.items.map((e) {
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
        .groupBy((p0) => containerMapperService
            .fromDao(containerStore.containers[p0.containerId]!))
        .mapValues((value) => value.fold(0, (prev, curr) => prev + curr.count));
  }

  List<RescueContainer> get containerValues => containerStore.containerValues
      .map(containerMapperService.fromDao)
      .toList();

  Map<String, String> otherContainerOptions(Item item) {
    return Map.fromEntries(containerValues
        .where((element) => !assignmentStore.assignments
            .any((a) => a.containerId == element.id && a.itemId == item.id))
        .map((e) => MapEntry(e.id, e.name)));
  }

  RescueContainer newContainer() =>
      containerMapperService.fromDao(containerStore.newContainer());
}

ProxyProvider5 proxyContainerService() => ProxyProvider5<
        ItemService,
        ContainerStore,
        ContainerMapperService,
        AssignmentStore,
        ContainerVisibilityService,
        ContainerService>(
    update: (ctx, itemService, containerStore, mapperService, assignmentStore,
            visibilityService, prev) =>
        ContainerService(itemService, containerStore, mapperService,
            assignmentStore, visibilityService));
