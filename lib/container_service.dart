import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_expander_service.dart';
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
  final AssignmentExpanderService assignmentExpanderService;

  ContainerService(this.itemService, this.containerStore,
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
        ItemService,
        ContainerStore,
        ContainerMapperService,
        AssignmentExpanderService,
        ContainerService>(
    update: (ctx, itemService, containerStore, mapperService,
            assignmentExpanderService, prev) =>
        ContainerService(itemService, containerStore, mapperService,
            assignmentExpanderService));
