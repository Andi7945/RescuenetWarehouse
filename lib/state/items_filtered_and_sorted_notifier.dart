import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/items_current_filter_notifier.dart';

import '../models/item.dart';
import 'items_current_sort_notifier.dart';

part 'items_filtered_and_sorted_notifier.g.dart';

@riverpod
class ItemsFilteredAndSortedNotifier extends _$ItemsFilteredAndSortedNotifier {
  @override
  List<Item> build() {
    var items = ref.watch(allItemsNotifierProvider);
    var sortOptions = ref.watch(itemsCurrentSortNotifierProvider);

    var itms = _filtered([...items]);

    var sortFn = sortOptions.asc
        ? sortOptions.sort
        : ((a, b) => (sortOptions.sort(a, b) * -1));
    itms.sort(sortFn);

    return itms;
  }

  _filtered(List<Item> itms) {
    var filterOptions = ref.watch(itemsCurrentFilterNotifierProvider);
    if (filterOptions.value != null) {
      return itms
          .where((itm) => filterOptions.filter.check(itm, filterOptions.value!))
          .toList();
    }
    return itms;
  }
}

/// Backward compatibility provider that returns the same as the original
@riverpod
List<Item> itemsFilteredAndSortedCompat(ItemsFilteredAndSortedCompatRef ref) {
  var items = ref.watch(allItemsNotifierProvider);
  var sortOptions = ref.watch(itemsCurrentSortNotifierProvider);
  var filterOptions = ref.watch(itemsCurrentFilterNotifierProvider);

  // Apply filtering
  var filteredItems = items;
  if (filterOptions.value != null) {
    filteredItems = items
        .where((itm) => filterOptions.filter.check(itm, filterOptions.value!))
        .toList();
  }

  // Apply sorting
  var sortFn = sortOptions.asc
      ? sortOptions.sort
      : ((a, b) => (sortOptions.sort(a, b) * -1));
  filteredItems.sort(sortFn);

  return filteredItems;
}

/// AsyncValue-based filtered and sorted items provider for loading states support.
/// 
/// This provider combines AsyncValue items data with filtering and sorting,
/// providing proper loading, error, and data states while applying the same
/// filtering and sorting logic as the original provider.
/// 
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Item>>(
///   value: ref.watch(itemsFilteredAndSortedAsyncProvider),
///   data: (items) => ItemGrid(items: items),
/// )
/// ```
@riverpod
class ItemsFilteredAndSortedAsync extends _$ItemsFilteredAndSortedAsync {
  @override
  AsyncValue<List<Item>> build() {
    final itemsAsync = ref.watch(allItemsAsyncProvider);
    final sortOptions = ref.watch(itemsCurrentSortNotifierProvider);
    final filterOptions = ref.watch(itemsCurrentFilterNotifierProvider);

    return itemsAsync.when(
      data: (items) {
        // Apply filtering
        var filteredItems = items;
        if (filterOptions.value != null) {
          filteredItems = items
              .where((itm) => filterOptions.filter.check(itm, filterOptions.value!))
              .toList();
        }

        // Apply sorting
        var sortFn = sortOptions.asc
            ? sortOptions.sort
            : ((a, b) => (sortOptions.sort(a, b) * -1));
        filteredItems.sort(sortFn);

        return AsyncValue.data(filteredItems);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }

  /// Refresh the filtered and sorted items data
  Future<void> refresh() async {
    ref.invalidate(allItemsAsyncProvider);
  }
}
