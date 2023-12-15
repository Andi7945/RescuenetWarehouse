import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/services/assignment_expander_service.dart';
import 'package:rescuenet_warehouse/stores.dart';

import 'dart:math';

import '../models/item.dart';
import '../main.dart';

class ItemService {
  final ItemStore _itemStore;
  final AssignmentExpanderService _assignmentExpanderService;

  ItemService(this._itemStore, this._assignmentExpanderService);

  List<Item> get items => _itemStore.all;

  Item newItem() {
    var newRescueNetId =
        _itemStore.all.map((e) => e.rescueNetId).reduce(max) + 1;
    var item = Item(id: uuid.v4(), totalAmount: 0, rescueNetId: newRescueNetId);
    updateItem(item);
    return item;
  }

  Item? itemById(String id) =>
      _itemStore.all.firstWhereOrNull((element) => element.id == id);

  updateItem(Item item) {
    _itemStore.upsert(item);
  }

  Map<RescueContainer, int> assignmentsFor(Item item) =>
      _assignmentExpanderService.assignmentsForItem(item.id);

  delete(Item item) => _itemStore.remove(item);
}

ProxyProvider2 provideItemService() =>
    ProxyProvider2<ItemStore, AssignmentExpanderService, ItemService>(
        update: (ctx, ItemStore itemStore, expander, prev) =>
            ItemService(itemStore, expander));
