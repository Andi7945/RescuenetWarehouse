import 'dart:math';

import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
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

  addItem() async {
    var newRescueNetId =
        ref
            .read(allItemsNotifierProvider)
            .map((e) => e.rescueNetId)
            .reduce(max) +
        1;
    var item = Item(id: uuid.v4(), totalAmount: 0, rescueNetId: newRescueNetId);
    await update(item);
  }

  setItem(Item item) {
    state = item;
  }

  update(Item item) async {
    state = item;
    
    // Use DataOperationsNotifier for proper loading state management
    final dataOperations = ref.read(dataOperationsNotifierProvider.notifier);
    final isNewItem = state?.id != item.id || 
        ref.read(allItemsNotifierProvider).every((existingItem) => existingItem.id != item.id);
    
    if (isNewItem) {
      await dataOperations.createItem(item);
    } else {
      await dataOperations.updateItem(item);
    }
  }

  delete() async {
    var id = state?.id;
    if (id != null) {
      state = null;
      // Use DataOperationsNotifier for proper loading state management
      await ref.read(dataOperationsNotifierProvider.notifier).deleteItem(id);
    }
  }
}
