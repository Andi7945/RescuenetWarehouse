import 'package:riverpod_annotation/riverpod_annotation.dart';

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
