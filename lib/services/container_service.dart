import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/services/assignment_expander_service.dart';
import 'package:rescuenet_warehouse/services/container_mapper_service.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/stores.dart';

import '../models/container_dao.dart';
import '../models/item.dart';
import '../models/sequential_build.dart';

class ContainerService {
  final ItemStore itemStore;
  final ContainerStore containerStore;
  final ContainerMapperService containerMapperService;
  final AssignmentExpanderService assignmentExpanderService;

  ContainerService(this.itemStore, this.containerStore,
      this.containerMapperService, this.assignmentExpanderService);

  List<RescueContainer> containers() {
    var conts = containerStore.all.map(containerMapperService.fromDao).toList();
    conts.sort((a, b) => a.number.compareTo(b.number));
    return conts;
  }

  updateContainer(ContainerDao container) {
    containerStore.upsert(container);
  }

  Future<RescueContainer> newContainer() async {
    var newContainer = ContainerDao(
        id: uuid.v4(),
        number: _firstUnusedNumber(),
        name: "",
        sequentialBuild: SequentialBuild.firstBuild,
        isReady: false,
        toDeploy: false);
    await containerStore.upsert(newContainer);
    return containerMapperService.fromDao(newContainer);
  }

  Future<void> deleteContainer(String containerId) =>
      containerStore.removeById(containerId);

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
        assignmentExpanderService.assignmentsFor(cont.id))));
  }

  Map<Item, int> itemsWithoutContainer() {
    var assignedItems = assignmentExpanderService.assignmentsFor();

    var map = Map.fromEntries(itemStore.all.map((e) {
      var assigned = assignedItems[e];
      if (assigned == null) {
        return MapEntry(e, e.totalAmount);
      }
      return MapEntry(e, e.totalAmount - assigned);
    }));

    map.removeWhere((key, value) => value == 0);

    return map;
  }

  Set<Item> itemsAssigned(RescueContainer container) =>
      assignmentExpanderService.assignmentsFor(container.id).keys.toSet();

  Map<RescueContainer, int> assignmentsFor(Item item) =>
      assignmentExpanderService.assignmentsForItem(item.id);

  List<RescueContainer> get containerValues =>
      containerStore.all.map(containerMapperService.fromDao).toList();

  List<RescueContainer> otherContainerOptions(Item item) {
    var alreadyAssigned =
        assignmentExpanderService.assignmentsForItem(item.id).keys;
    return [
      for (RescueContainer cont in containerValues)
        if (!alreadyAssigned.contains(cont)) cont
    ];
  }
}

ProxyProvider4 proxyContainerService() => ProxyProvider4<
        ItemStore,
        ContainerStore,
        ContainerMapperService,
        AssignmentExpanderService,
        ContainerService>(
    update: (ctx, itemStore, containerStore, mapperService,
            assignmentExpanderService, prev) =>
        ContainerService(itemStore, containerStore, mapperService,
            assignmentExpanderService));
