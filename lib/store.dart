import 'dart:collection';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

import 'assignment.dart';
import 'data_mocks.dart';

class Store extends ChangeNotifier {
  final List<Item> _items = [
    item_fire,
    item_chair,
    item_desk,
    item_generator,
    item_cooler,
    item_para,
    item_splint
  ];

  final Map<String, RescueContainer> _containers = {
    container_office.id: container_office,
    container_power.id: container_power,
    container_medical.id: container_medical
  };

  final Map<String, bool> _containerVisibility = {
    container_office.id: true,
    container_power.id: true,
    container_medical.id: true
  };

  final List<Assignment> _assignments = [
    assignment_item1_container1,
    assignment_item1_container3
  ];

  UnmodifiableListView<Assignment> get assignments =>
      UnmodifiableListView(_assignments);

  Map<RescueContainer, int> assignmentsFor(Item item) {
    return _assignments
        .where((a) => a.itemId == item.id)
        .groupBy((p0) => _containers[p0.containerId]!)
        .mapValues((value) => value.fold(0, (prev, curr) => prev + curr.count));
  }

  List<String> otherContainerOptions(Item item) {
    return containers
        .where((element) => !assignments
            .any((a) => a.containerId == element.id && a.itemId == item.id))
        .map((e) => e.name)
        .whereNotNull()
        .toList();
  }

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Item itemById(String id) => _items.firstWhere((element) => element.id == id);

  UnmodifiableListView<RescueContainer> get containers =>
      UnmodifiableListView(_containers.values);

  Map<RescueContainer, bool> containerWithVisible() => _containerVisibility
      .map((key, value) => MapEntry(_containers[key]!, value));

  changeContainerVisibility(RescueContainer c) {
    _containerVisibility.update(c.id, (value) => !value);
    notifyListeners();
  }

  changeAllContainerVisibility(bool shown) {
    _containerVisibility.updateAll((key, value) => value = shown);
    notifyListeners();
  }

  Map<RescueContainer, Map<Item, int>> containerWithItems() {
    return Map.fromEntries(_containers.values.map((cont) => MapEntry(
        cont,
        Map.fromEntries(_assignments
            .where((assignment) => assignment.containerId == cont.id)
            .map((assignment) =>
                MapEntry(itemById(assignment.itemId), assignment.count))))));
  }

  Map<Item, int> itemsWithoutContainer() {
    var assignedItems = _assignments.groupBy((p0) => p0.itemId).map(
        (key, value) => MapEntry(
            itemById(key),
            value.fold(
                0, (previousValue, element) => previousValue + element.count)));

    var map = Map.fromEntries(_items.map((e) {
      var assigned = assignedItems[e];
      if (assigned == null) {
        return MapEntry(e, e.totalAmount);
      }
      return MapEntry(e, e.totalAmount - assigned);
    }));

    map.removeWhere((key, value) => value == 0);

    return map;
  }

  RescueContainer containerById(String id) => _containers[id]!;

  updateContainer(RescueContainer container) {
    _containers[container.id] = container;
    notifyListeners();
  }

  addContainer(BuildContext context, String containerName, Item item) {
    var container =
        containers.firstWhere((element) => element.name == containerName);
    if (_assignments.none((element) =>
        element.containerId == container.id && element.itemId == item.id)) {
      _assignments.add(Assignment(item.id, container.id, 1));
      Provider.of<WorkLogStore>(context, listen: false)
          .add(Assignment(item.id, container.id, 1));
      notifyListeners();
    }
  }

  updateItem(Item item) {
    var idx = _items.indexWhere((element) => element.id == item.id);
    if (idx != -1) {
      _items.replaceRange(idx, idx + 1, [item]);
      notifyListeners();
    }
  }

  increase(BuildContext context, Item item, String containerId) {
    _assignments
        .firstWhere((element) =>
            element.itemId == item.id && element.containerId == containerId)
        .count += 1;
    _assignments.removeWhere((element) => element.count == 0);
    Provider.of<WorkLogStore>(context, listen: false)
        .add(Assignment(item.id, containerId, 1));
    notifyListeners();
  }

  reduce(BuildContext context, Item item, String containerId) {
    _assignments
        .firstWhere((element) =>
            element.itemId == item.id && element.containerId == containerId)
        .count -= 1;
    _assignments.removeWhere((element) => element.count == 0);
    Provider.of<WorkLogStore>(context, listen: false)
        .add(Assignment(item.id, containerId, -1));
    notifyListeners();
  }
}
