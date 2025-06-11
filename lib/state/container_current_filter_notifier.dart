import 'package:rescuenet_warehouse/filter_fields.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../container_filter.dart';

part 'container_current_filter_notifier.g.dart';

@riverpod
class ContainerCurrentFilterNotifier extends _$ContainerCurrentFilterNotifier {
  @override
  ContainerFilter build() {
    return ContainerFilter(FilterField.all, null);
  }

  setField(FilterField? field) =>
      state = ContainerFilter(field ?? FilterField.all, null);

  setCurrentFilterValue(String? v) => state = ContainerFilter(state.field, v);
}
