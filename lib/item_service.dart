import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_store.dart';

import 'item.dart';

class ItemService {
  final ItemStore itemStore;

  ItemService(this.itemStore);

  List<Item> get items => itemStore.items;

  Item newItem() => itemStore.newItem();

  Item itemById(String id) =>
      itemStore.items.firstWhere((element) => element.id == id);

  updateItem(Item item) {
    itemStore.updateItem(item);
  }
}

ProxyProvider provideItemService() => ProxyProvider<ItemStore, ItemService>(
    update: (ctx, ItemStore itemStore, prev) => ItemService(itemStore));
