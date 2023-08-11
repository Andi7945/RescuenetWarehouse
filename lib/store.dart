import 'dart:collection';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

import 'assignment.dart';
import 'container_dao.dart';
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

  final Map<String, ContainerDao> containers = {
    container_office.id: container_office,
    container_power.id: container_power,
    container_medical.id: container_medical
  };

  final Map<String, bool> containerVisibility = {
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

  List<String> otherContainerOptions(Item item) {
    return containerValues
        .where((element) => !assignments
            .any((a) => a.containerId == element.id && a.itemId == item.id))
        .map((e) => e.name)
        .whereNotNull()
        .toList();
  }

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Item itemById(String id) => _items.firstWhere((element) => element.id == id);

  UnmodifiableListView<ContainerDao> get containerValues =>
      UnmodifiableListView(containers.values);

  changeContainerVisibility(RescueContainer c) {
    containerVisibility.update(c.id, (value) => !value);
    notifyListeners();
  }

  changeAllContainerVisibility(bool shown) {
    containerVisibility.updateAll((key, value) => value = shown);
    notifyListeners();
  }

  ContainerDao containerById(String id) => containers[id]!;

  updateContainer(ContainerDao container) {
    containers[container.id] = container;
    notifyListeners();
  }

  addContainer(BuildContext context, String containerName, Item item) {
    var container =
        containerValues.firstWhere((element) => element.name == containerName);
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
