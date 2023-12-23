import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_filter.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/services/item_service.dart';

class ItemFilterService extends ChangeNotifier {
  List<Item> _items;
  final ValueNotifier<ItemFilter?> _currentFilter;
  String? _currentFilterValue;

  ItemFilterService(this._items) : _currentFilter = ValueNotifier(null) {
    _currentFilter.addListener(() {
      notifyListeners();
    });
  }

  List<Item> get items => _filteredItems();

  int get filteredItemsSize => items.length;

  int get unfilteredItemsSize => _items.length;

  ValueNotifier<ItemFilter?> get currentFilter => _currentFilter;

  String? get currentFilterValue => _currentFilterValue;

  setCurrentFilterValue(String? v) {
    _currentFilterValue = v;
    notifyListeners();
  }

  updateItems(List<Item> it) {
    _items = it;
    notifyListeners();
  }

  _filteredItems() {
    var itms = [..._items];
    if (_currentFilter.value != null && _currentFilterValue != null) {
      return itms
          .where(
              (itm) => _currentFilter.value!.check(itm, _currentFilterValue!))
          .toList();
    }
    return itms;
  }
}

ChangeNotifierProxyProvider<ItemService, ItemFilterService>
    provideItemFilterService() => ChangeNotifierProxyProvider(
        create: (ctx) => ItemFilterService([]),
        update: (ctx, itemService, prev) =>
            prev!..updateItems(itemService.items));
