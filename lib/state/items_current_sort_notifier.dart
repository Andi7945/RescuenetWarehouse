import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/item_sorting_options.dart';

part 'items_current_sort_notifier.g.dart';

@riverpod
class ItemsCurrentSortNotifier extends _$ItemsCurrentSortNotifier {
  @override
  ItemSortingOption build() {
    return itemSortingOptions.first;
  }

  set(ItemSortingOption option) => state = option.copyWith(
      asc: state.displayName == option.displayName ? !state.asc : state.asc);
}
