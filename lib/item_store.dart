import 'dart:collection';

import 'package:flutter/material.dart';

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
}
