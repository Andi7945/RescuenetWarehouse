import 'dart:collection';

import 'package:flutter/material.dart';
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

  final List<RescueContainer> _containers = [
    container_office,
    container_power,
    container_medical
  ];

  final List<ContainerType> _containerTypes = [
    container_type_crate,
    container_type_backpack
  ];

  final List<String> _moduleDestinations = ["Office", "Warehouse"];

  final List<String> _currentLocations = ["Warehouse Shiphole NL", "Office"];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Item itemById(String id) => _items.firstWhere((element) => element.id == id);

  UnmodifiableListView<RescueContainer> get containers =>
      UnmodifiableListView(_containers);

  UnmodifiableListView<ContainerType> get containerTypes =>
      UnmodifiableListView(_containerTypes);

  UnmodifiableListView<String> get moduleDestinations =>
      UnmodifiableListView(_moduleDestinations);

  UnmodifiableListView<String> get currentLocations =>
      UnmodifiableListView(_currentLocations);
}
