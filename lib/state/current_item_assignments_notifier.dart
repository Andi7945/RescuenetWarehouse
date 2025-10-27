import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/services/assignment/assignment_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/rescue_container.dart';

part 'current_item_assignments_notifier.g.dart';

@riverpod
class CurrentItemAssignmentsNotifier extends _$CurrentItemAssignmentsNotifier {
  @override
  Map<RescueContainer, int> build() {
    var currentItem = ref.watch(currentItemNotifierProvider);
    if (currentItem == null) return {};
    var assignmentsAsync = ref.watch(allAssignmentsAsyncProvider);
    var containersAsync = ref.watch(allContainersAsyncProvider);

    return assignmentsAsync.when(
      data: (assignments) {
        return containersAsync.when(
          data: (containers) {
            var grouped = assignments
                .where((a) => a.itemId == currentItem.id)
                .groupBy((a) => a.containerId);

            Map<RescueContainer, int> result = {};
            for (var entry in grouped.entries) {
              var container = containers.firstWhereOrNull(
                (c) => c.id == entry.key,
              );
              if (container != null) {
                result[container] = _sumAmounts(entry.value);
              }
            }
            return result;
          },
          loading: () => <RescueContainer, int>{},
          error: (_, __) => <RescueContainer, int>{},
        );
      },
      loading: () => <RescueContainer, int>{},
      error: (_, __) => <RescueContainer, int>{},
    );
  }

  int _sumAmounts(List<Assignment> assignments) => assignments.fold(
    0,
    (previousValue, element) => previousValue + element.count,
  );

  Future<void> addContainerAssignment(
    String containerIdToAdd,
    int amount,
  ) async {
    var currentItem = ref.read(currentItemNotifierProvider);

    // Check if assignment already exists to prevent duplicates
    var existingAssignment = ref
        .read(allAssignmentsAsyncProvider.notifier)
        .byIds(currentItem!.id, containerIdToAdd);

    if (existingAssignment != null) {
      // Update existing assignment instead of creating duplicate
      await setAmount(containerIdToAdd, amount);
      return;
    }

    // Use service to create assignment (handles work log automatically)
    final service = ref.read(assignmentServiceProvider);
    await service.createAssignment(
      itemId: currentItem.id,
      containerId: containerIdToAdd,
      initialCount: amount,
    );
  }

  Future<void> setAmount(String containerId, int amount) async {
    var item = ref.read(currentItemNotifierProvider)!;

    // Use service to update assignment (handles work log automatically)
    final service = ref.read(assignmentServiceProvider);
    await service.updateAssignment(
      itemId: item.id,
      containerId: containerId,
      newAmount: amount,
    );
  }
}
