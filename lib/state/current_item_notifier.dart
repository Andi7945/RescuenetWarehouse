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
    final itemsAsync = ref.read(allItemsAsyncProvider);
    double newRescueNetId = itemsAsync.when(
      data: (items) => items.map((e) => e.rescueNetId).reduce(max) + 1,
      loading: () => 1.0, // Default to 1 if still loading
      error: (_, __) => 1.0, // Default to 1 on error
    );
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
    final itemsAsync = ref.read(allItemsAsyncProvider);
    final isNewItem = state?.id != item.id ||
        itemsAsync.when(
          data: (items) => items.every((existingItem) => existingItem.id != item.id),
          loading: () => true, // Assume new if still loading
          error: (_, __) => true, // Assume new on error
        );

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
