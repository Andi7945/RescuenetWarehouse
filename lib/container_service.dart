import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_container_types.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'container_dao.dart';
import 'item.dart';
import 'store.dart';

class ContainerService {
  final Store store;
  final StoreContainerTypes storeContainerTypes;

  ContainerService(this.store, this.storeContainerTypes);

  Map<RescueContainer, bool> containerWithVisible() => store.containerVisibility
      .map((key, value) => MapEntry(fromDao(store.containers[key]!), value));

  RescueContainer fromDao(ContainerDao dao) => RescueContainer.fromDao(
      dao,
      storeContainerTypes.containerTypes
          .firstWhere((type) => type.id == dao.typeId));

  Map<RescueContainer, Map<Item, int>> containerWithItems() {
    return Map.fromEntries(store.containers.values.map((cont) => MapEntry(
        fromDao(cont),
        Map.fromEntries(store.assignments
            .where((assignment) => assignment.containerId == cont.id)
            .map((assignment) => MapEntry(
                store.itemById(assignment.itemId), assignment.count))))));
  }

  Map<Item, int> itemsWithoutContainer() {
    var assignedItems = store.assignments.groupBy((p0) => p0.itemId).map(
        (key, value) => MapEntry(
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
    return store.assignments
        .where((a) => a.itemId == item.id)
        .groupBy((p0) => fromDao(store.containers[p0.containerId]!))
        .mapValues((value) => value.fold(0, (prev, curr) => prev + curr.count));
  }

  List<RescueContainer> get containerValues =>
      store.containerValues.map(fromDao).toList();
}
