import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item_sorting_options.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/assignable_items_notifier.dart';
import 'package:rescuenet_warehouse/state/items_current_filter_notifier.dart';

import '../../../models/item.dart';

List<(Item, int)> assignableItems(
  WidgetRef ref,
  String containerId,
  CurrentItemFilter itemFilter,
  bool hideWithoutRemainingAmount,
  ItemSortingOption sorting,
) {
  final itemsAssignableAsync = ref.watch(assignableItemsAsyncProvider);
  final assignmentsAsync = ref.watch(allAssignmentsAsyncProvider);
  
  // Return empty list if either assignable items or assignments are loading or in error state
  final itemsAssignable = itemsAssignableAsync.valueOrNull;
  final assignments = assignmentsAsync.valueOrNull;
  if (itemsAssignable == null || assignments == null) {
    return [];
  }
  
  var alreadyAssigned = assignments
      .where((a) => a.containerId == containerId && a.count != 0)
      .map((a) => a.itemId)
      .toList();

  var available =
      itemsAssignable.entries
          .where((i) => !alreadyAssigned.contains(i.key.id))
          .where((i) => !hideWithoutRemainingAmount || (i.value > 0))
          .map((entry) {
            final MapEntry(key: item, value: amount) = entry;
            return (item, amount);
          })
          .where(_filterFn(itemFilter))
          .toList();
  available.sort(_sortFn(sorting));
  return available;
}

int Function((Item, int) a, (Item, int) b) _sortFn(
  ItemSortingOption sortOptions,
) {
  var sortFn =
      sortOptions.asc
          ? sortOptions.sort
          : ((a, b) => (sortOptions.sort(a, b) * -1));
  return (a, b) => sortFn(a.$1, b.$1);
}

bool Function((Item, int) element) _filterFn(CurrentItemFilter filterOptions) {
  return (itm) =>
      filterOptions.value == null ||
      filterOptions.filter.check(itm.$1, filterOptions.value!);
}
