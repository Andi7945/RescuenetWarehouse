import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_options.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

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

  RescueContainer containerById(String id) => _containers[id]!;

  updateContainer(RescueContainer container) {
    _containers[container.id] = container;
    notifyListeners();
  }

  UnmodifiableListView<ContainerType> get containerTypes =>
      UnmodifiableListView(_containerTypes);

  UnmodifiableListView<String> get moduleDestinations =>
      UnmodifiableListView(_moduleDestinations);

  UnmodifiableListView<String> get currentLocations =>
      UnmodifiableListView(_currentLocations);

  ContainerOptions get containerOptions =>
      ContainerOptions(containerTypes, moduleDestinations, currentLocations);
}
