import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../item_filter.dart';

part 'items_current_filter_notifier.g.dart';

part 'items_current_filter_notifier.freezed.dart';

@riverpod
class ItemsCurrentFilterNotifier extends _$ItemsCurrentFilterNotifier {
  @override
  CurrentItemFilter build() {
    return CurrentItemFilter(filter: allItemFilter.values.first, value: null);
  }

  setField(ItemFilter? filter) => state = CurrentItemFilter(
    filter: filter ?? allItemFilter.values.first,
    value: null,
  );

  setCurrentFilterValue(String? v) => state = state.copyWith(value: v);
}

@freezed
abstract class CurrentItemFilter with _$CurrentItemFilter {
  factory CurrentItemFilter({
    required ItemFilter filter,
    required String? value,
  }) = _CurrentItemFilter;
}
