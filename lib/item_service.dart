import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/stores.dart';

import 'dart:math';

import 'item.dart';
import 'main.dart';

class ItemService {
  final ItemStore itemStore;

  ItemService(this.itemStore);

  List<Item> get items => itemStore.all;

  Item newItem() {
    var newRescueNetId =
        itemStore.all.map((e) => e.rescueNetId).reduce(max) + 1;
    var item = Item(uuid.v4(), 0, newRescueNetId);
    updateItem(item);
    return item;
  }

  Item itemById(String id) =>
      itemStore.all.firstWhere((element) => element.id == id);

  updateItem(Item item) {
    itemStore.upsert(item);
  }
}

ProxyProvider provideItemService() => ProxyProvider<ItemStore, ItemService>(
    update: (ctx, ItemStore itemStore, prev) => ItemService(itemStore));
