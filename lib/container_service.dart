import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/container_mapper_service.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/stores.dart';

import 'container_dao.dart';
import 'item.dart';
import 'item_service.dart';
import 'sequential_build.dart';

class ContainerService {
  final ItemService itemService;
  final ContainerStore containerStore;
  final ContainerMapperService containerMapperService;
  final AssignmentStore assignmentStore;

  ContainerService(this.itemService, this.containerStore,
      this.containerMapperService, this.assignmentStore);

  List<RescueContainer> containers() =>
      containerStore.all.map(containerMapperService.fromDao).toList();

  updateContainer(ContainerDao container) {
    containerStore.upsert(container);
  }

  RescueContainer newContainer() {
    var newContainer = ContainerDao(uuid.v4(), _firstUnusedNumber(), "", null,
        null, SequentialBuild.firstBuild, null, null, false, false);
    containerStore.upsert(newContainer);
    return containerMapperService.fromDao(newContainer);
  }

  int _firstUnusedNumber() {
    var containerNumbers = containerStore.all.map((c) => c.number).toList();
    containerNumbers.sort();

    var value = 1;
    for (int curr in containerNumbers) {
      if (curr != value) {
        break;
      }
      value = curr + 1;
    }
    return value;
  }

  Map<RescueContainer, Map<Item, int>> containerWithItems() {
    return Map.fromEntries(containerStore.all.map((cont) => MapEntry(
        containerMapperService.fromDao(cont),
        Map.fromEntries(assignmentStore.all
            .where((assignment) => assignment.containerId == cont.id)
            .map((assignment) => MapEntry(
                itemService.itemById(assignment.itemId), assignment.count))))));
  }

  Map<Item, int> itemsWithoutContainer() {
    var assignedItems = assignmentStore.all.groupBy((p0) => p0.itemId).map(
        (key, value) => MapEntry(
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
    return assignmentStore.all
        .where((a) => a.itemId == item.id)
        .groupBy((p0) =>
            containerMapperService.fromDao(containerStore.get(p0.containerId)))
        .mapValues((value) => value.fold(0, (prev, curr) => prev + curr.count));
  }

  List<RescueContainer> get containerValues =>
      containerStore.all.map(containerMapperService.fromDao).toList();

  Map<String, String> otherContainerOptions(Item item) {
    return Map.fromEntries(containerValues
        .where((element) => !assignmentStore.all
            .any((a) => a.containerId == element.id && a.itemId == item.id))
        .map((e) => MapEntry(e.id, e.name)));
  }
}

ProxyProvider4 proxyContainerService() => ProxyProvider4<
        ItemService,
        ContainerStore,
        ContainerMapperService,
        AssignmentStore,
        ContainerService>(
    update: (ctx, itemService, containerStore, mapperService, assignmentStore,
            prev) =>
        ContainerService(
            itemService, containerStore, mapperService, assignmentStore));
