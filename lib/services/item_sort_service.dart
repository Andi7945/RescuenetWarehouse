import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/services/item_service.dart';
import 'package:rescuenet_warehouse/models/item_sorting_options.dart';

class ItemSortService extends ChangeNotifier {
  List<Item> _items;
  var _sortedBy = itemSortingOptions.first;
  var _sortAsc = true;

  ItemSortingOption get sortedBy => _sortedBy;

  bool get sortedAsc => _sortAsc;

  List<Item> get items => sortedItems();

  ItemSortService(this._items);

  updateItems(List<Item> it) {
    _items = it;
    notifyListeners();
  }

  List<Item> sortedItems() {
    var itms = [..._items];
    var sortFn =
        _sortAsc ? _sortedBy.sort : ((a, b) => (_sortedBy.sort(a, b) * -1));
    itms.sort(sortFn);
    return itms;
  }

  setOption(ItemSortingOption option) {
    _sortAsc = _sortedBy != option || !_sortAsc;
    _sortedBy = option;
    notifyListeners();
  }
}

ChangeNotifierProxyProvider<ItemService, ItemSortService>
    provideItemSortService() =>
        ChangeNotifierProxyProvider<ItemService, ItemSortService>(
          create: (ctx) => ItemSortService([]),
          update: (ctx, itemService, prev) =>
              prev!..updateItems(itemService.items),
        );
