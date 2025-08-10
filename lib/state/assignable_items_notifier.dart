import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/item.dart';

part 'assignable_items_notifier.g.dart';

@riverpod
class AssignableItemsNotifier extends _$AssignableItemsNotifier {
  @override
  Map<Item, int> build() {
    var assignments = ref.watch(allAssignmentsNotifierProvider);
    var alreadyAssigned = assignments
        .groupBy((a) => a.itemId)
        .mapValues((a) => a.fold(0, (p, e) => p + e.count));
    var items = ref.watch(allItemsNotifierProvider);
    //print("Items in ass: $items");
    return Map.fromEntries(items.map((i) {
      if (alreadyAssigned[i.id] == null ||
          i.totalAmount <= alreadyAssigned[i.id]!) {
        return MapEntry(i, i.totalAmount - (alreadyAssigned[i.id] ?? 0));
      }
    }).nonNulls);
  }
}
