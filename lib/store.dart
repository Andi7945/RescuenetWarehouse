import 'dart:collection';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item.dart';

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

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Item itemById(String id) => _items.firstWhere((element) => element.id == id);

  UnmodifiableListView<ContainerDao> get containerValues =>
      UnmodifiableListView(containers.values);

  updateContainer(ContainerDao container) {
    containers[container.id] = container;
    notifyListeners();
  }

  updateItem(Item item) {
    var idx = _items.indexWhere((element) => element.id == item.id);
    if (idx != -1) {
      _items.replaceRange(idx, idx + 1, [item]);
      notifyListeners();
    }
  }
}
