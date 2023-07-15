import 'dart:collection';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_options.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'assignment.dart';
import 'container_type.dart';
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
        .map((key, value) =>
            MapEntry(key, value.fold(0, (prev, curr) => prev + curr.count)));
  }

  List<String> otherContainerOptions(Item item) {
    return containers
        .where((element) => !assignments
            .any((a) => a.containerId == element.id && a.itemId == item.id))
        .map((e) => e.name)
        .whereNotNull()
        .toList();
  }

  final List<ContainerType> _containerTypes = [
    container_type_crate,
    container_type_backpack
  ];

  final List<String> _moduleDestinations = ["Office", "Warehouse"];

  final List<String> _currentLocations = ["Warehouse Shiphole NL", "Office"];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Item itemById(String id) => _items.firstWhere((element) => element.id == id);

  UnmodifiableListView<RescueContainer> get containers =>
      UnmodifiableListView(_containers.values);

  Map<RescueContainer, Map<Item, int>> containerWithItems() {
    return Map.fromEntries(_containers.values.map((cont) => MapEntry(
        cont,
        Map.fromEntries(_assignments
            .where((assignment) => assignment.containerId == cont.id)
            .map((assignment) =>
                MapEntry(itemById(assignment.itemId), assignment.count))))));
  }

  RescueContainer containerById(String id) => _containers[id]!;

  updateContainer(RescueContainer container) {
    _containers[container.id] = container;
    notifyListeners();
  }

  addContainer(String containerName, Item item) {
    var container =
        containers.firstWhere((element) => element.name == containerName);
    if (_assignments.none((element) =>
        element.containerId == container.id && element.itemId == item.id)) {
      _assignments.add(Assignment(item.id, container.id, 1));
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

  UnmodifiableListView<ContainerType> get containerTypes =>
      UnmodifiableListView(_containerTypes);

  UnmodifiableListView<String> get moduleDestinations =>
      UnmodifiableListView(_moduleDestinations);

  Map<String, Set<String>> get moduleDestinationsWithUsage {
    Map<String, Set<String>> grouped = _containers.values
        .where((element) => element.moduleDestination != null)
        .groupBy((p0) => p0.moduleDestination!)
        .map((key, value) =>
            MapEntry(key, value.map((e) => e.name).whereNotNull().toSet()));

    Map<String, Set<String>> map = {
      for (var e in _moduleDestinations) e: grouped[e] ?? Set()
    };

    return map;
  }

  addDestination(String? text) {
    if (text != null && !_moduleDestinations.contains(text)) {
      _moduleDestinations.add(text);
      notifyListeners();
    }
  }

  removeDestination(String? text) {
    if (_moduleDestinations.contains(text)) {
      _moduleDestinations.remove(text);
      notifyListeners();
    }
  }

  editDestination(String oldDest, String newDest) {
    var idx = _moduleDestinations.indexOf(oldDest);
    if (idx != -1) {
      _moduleDestinations.replaceRange(idx, idx + 1, [newDest]);
      notifyListeners();
    }
  }

  UnmodifiableListView<String> get currentLocations =>
      UnmodifiableListView(_currentLocations);

  ContainerOptions get containerOptions =>
      ContainerOptions(containerTypes, moduleDestinations, currentLocations);

  increase(Item item, String containerId) {
    _assignments
        .firstWhere((element) =>
            element.itemId == item.id && element.containerId == containerId)
        .count += 1;
    notifyListeners();
  }

  reduce(Item item, String containerId) {
    _assignments
        .firstWhere((element) =>
            element.itemId == item.id && element.containerId == containerId)
        .count -= 1;
    notifyListeners();
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
