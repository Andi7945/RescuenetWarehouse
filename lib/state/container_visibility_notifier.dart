import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/container_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/state/container_hidden_by_selection_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container_visibility_notifier.g.dart';

@riverpod
class ContainerVisibilityNotifier extends _$ContainerVisibilityNotifier {
  @override
  Map<RescueContainer, bool> build() {
    var container = ref.watch(allContainersNotifierProvider);
    var filter = ref.watch(containerCurrentFilterNotifierProvider);
    var assignments = ref.watch(allAssignmentsNotifierProvider.notifier);
    var items = ref.watch(allItemsNotifierProvider.notifier);
    var hiddenContainers =
        ref.watch(containerHiddenBySelectionNotifierProvider);
    return Map.fromEntries(container.map((c) {
      if (hiddenContainers.contains(c)) {
        return MapEntry(c, false);
      }
      var itms = assignments
          .byContainer(c.id)
          .map((a) => items.byId(a.itemId))
          .nonNulls
          .toList();
      return MapEntry(c, filter.matches(c, itms));
    }));
  }
}
