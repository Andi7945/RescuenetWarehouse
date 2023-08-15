import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/main.dart';

import 'data_mocks.dart';
import 'item.dart';

class ItemStore extends ChangeNotifier {
  final List<Item> _items = [
    item_fire,
    item_chair,
    item_desk,
    item_generator,
    item_cooler,
    item_para,
    item_splint
  ];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  updateItem(Item item) {
    var idx = _items.indexWhere((element) => element.id == item.id);
    if (idx != -1) {
      _items.replaceRange(idx, idx + 1, [item]);
      notifyListeners();
    }
  }

  newItem() {
    var newRescueNetId = _items.map((e) => e.rescueNetId).reduce(max) + 1;
    var item = Item(uuid.v4(), 0, newRescueNetId);
    _items.add(item);
    return item;
  }
}
