import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/assignment.dart';
import '../models/item.dart';
import '../models/rescue_container.dart';
import 'all_assignments_notifier.dart';
import 'all_items_notifier.dart';

part 'container_with_items_notifier.g.dart';

@riverpod
class ContainerWithItemsNotifier extends _$ContainerWithItemsNotifier {
  @override
  Map<RescueContainer, Map<Item, int>> build() {
    var assignmentsAsync = ref.watch(allAssignmentsAsyncProvider);
    var containersAsync = ref.watch(allContainersAsyncProvider);

    return assignmentsAsync.when(
      data: (assignments) => containersAsync.when(
        data: (containers) => _container(assignments, containers),
        loading: () => <RescueContainer, Map<Item, int>>{},
        error: (_, __) => <RescueContainer, Map<Item, int>>{},
      ),
      loading: () => <RescueContainer, Map<Item, int>>{},
      error: (_, __) => <RescueContainer, Map<Item, int>>{},
    );
  }

  Map<RescueContainer, Map<Item, int>> _container(
    List<Assignment> assignments,
    List<RescueContainer> containers,
  ) {
    var entries = assignments.groupBy((a) => a.containerId).entries.map((e) {
      var cont = containers.firstWhereOrNull(
        (container) => container.id == e.key,
      );
      if (cont != null) {
        return MapEntry(cont, _items(e.value));
      }
      return null;
    }).nonNulls;
    return Map.fromEntries(entries);
  }

  Map<Item, int> _items(List<Assignment> assignments) {
    var itemsAsync = ref.watch(allItemsAsyncProvider);
    return itemsAsync.when(
      data: (items) {
        return Map.fromEntries(
          assignments.map((a) {
            var item = items.firstWhereOrNull((item) => item.id == a.itemId);
            if (item != null) {
              return MapEntry(item, a.count);
            }
          }).nonNulls,
        );
      },
      loading: () => <Item, int>{},
      error: (_, __) => <Item, int>{},
    );
  }
}
