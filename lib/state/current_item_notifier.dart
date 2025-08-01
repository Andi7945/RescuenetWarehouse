import 'dart:math';

import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../main.dart';
import '../models/item.dart';

part 'current_item_notifier.g.dart';

@riverpod
class CurrentItemNotifier extends _$CurrentItemNotifier {
  @override
  Item? build() {
    return null;
  }

  addItem() {
    var newRescueNetId =
        ref
            .read(allItemsNotifierProvider)
            .map((e) => e.rescueNetId)
            .reduce(max) +
        1;
    var item = Item(id: uuid.v4(), totalAmount: 0, rescueNetId: newRescueNetId);
    update(item);
  }

  setItem(Item item) {
    state = item;
  }

  update(Item item) async {
    state = item;
    await ref.read(itemRepositoryProvider).upsertItem(item);
  }

  delete() async {
    var id = state?.id;
    if (id != null) {
      state = null;
      await ref.read(itemRepositoryProvider).deleteItem(id);
    }
  }
}
