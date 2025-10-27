import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/container_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/state/container_hidden_by_selection_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container_visibility_notifier.g.dart';

/// AsyncValue-based container visibility provider for loading states support.
///
/// This provider works with the AsyncValue-based containers provider to provide
/// proper loading and error states for container visibility filtering.
@riverpod
class ContainerVisibilityAsync extends _$ContainerVisibilityAsync {
  @override
  Stream<Map<RescueContainer, bool>> build() async* {
    // Watch the async containers stream
    final containersAsync = ref.watch(allContainersAsyncProvider);
    final filter = ref.watch(containerCurrentFilterNotifierProvider);
    final assignmentsAsync = ref.watch(allAssignmentsAsyncProvider);
    final items = ref.watch(allItemsNotifierProvider.notifier);
    final hiddenContainers = ref.watch(
      containerHiddenBySelectionNotifierProvider,
    );

    // Emit visibility map based on current containers and assignments state
    yield* assignmentsAsync.when(
      data: (assignments) async* {
        yield* containersAsync.when(
          data: (containers) async* {
            final visibilityMap = Map.fromEntries(
              containers.map((c) {
                if (hiddenContainers.contains(c)) {
                  return MapEntry(c, false);
                }
                var itms = assignments
                    .where((a) => a.containerId == c.id)
                    .map((a) => items.byId(a.itemId))
                    .nonNulls
                    .toList();
                return MapEntry(c, filter.matches(c, itms));
              }),
            );
            yield visibilityMap;
          },
          loading: () async* {
            // While loading containers, yield empty map
            yield <RescueContainer, bool>{};
          },
          error: (error, stackTrace) async* {
            // On error, yield empty map (could also throw the error)
            yield <RescueContainer, bool>{};
          },
        );
      },
      loading: () async* {
        // While loading assignments, yield empty map
        yield <RescueContainer, bool>{};
      },
      error: (error, stackTrace) async* {
        // On error, yield empty map (could also throw the error)
        yield <RescueContainer, bool>{};
      },
    );
  }

  /// Get visible containers from the current async state
  List<RescueContainer> getVisibleContainers() {
    final visibilityMap = state.valueOrNull ?? <RescueContainer, bool>{};
    final visibleContainers = visibilityMap.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Sort by container number
    visibleContainers.sort((a, b) => a.number.compareTo(b.number));
    return visibleContainers;
  }
}
