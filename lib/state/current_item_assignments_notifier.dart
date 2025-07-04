import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/db/assignment_data.dart';
import 'package:rescuenet_warehouse/db/work_log_data.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth_util.dart';
import '../main.dart';
import '../models/item.dart';
import '../models/log_entry.dart';
import '../models/rescue_container.dart';

part 'current_item_assignments_notifier.g.dart';

@riverpod
class CurrentItemAssignmentsNotifier extends _$CurrentItemAssignmentsNotifier {
  @override
  Map<RescueContainer, int> build() {
    var currentItem = ref.watch(currentItemNotifierProvider);
    if (currentItem == null) return {};
    var assignments = ref.watch(allAssignmentsNotifierProvider);

    var containerNotifier = ref.watch(allContainersNotifierProvider.notifier);
    var grouped = assignments
        .where((a) => a.itemId == currentItem.id)
        .groupBy((a) => a.containerId)
        .map((k, v) => MapEntry(containerNotifier.byId(k)!, _sumAmounts(v)));

    return grouped;
  }

  int _sumAmounts(List<Assignment> assignments) => assignments.fold(
    0,
    (previousValue, element) => previousValue + element.count,
  );

  addContainerAssignment(String containerIdToAdd, int amount) {
    var currentItem = ref.read(currentItemNotifierProvider);
    
    // Check if assignment already exists to prevent duplicates
    var existingAssignment = ref
        .read(allAssignmentsNotifierProvider.notifier)
        .byIds(currentItem!.id, containerIdToAdd);
    
    if (existingAssignment != null) {
      // Update existing assignment instead of creating duplicate
      setAmount(containerIdToAdd, amount);
      return;
    }
    
    var assignment = Assignment(
      id: uuid.v4(),
      itemId: currentItem.id,
      containerId: containerIdToAdd,
      count: amount,
    );

    ref.read(assignmentDataProvider.notifier).upsertOrDelete(assignment);
    var log = _buildEntry(currentItem, containerIdToAdd, amount);
    ref.read(workLogDataProvider.notifier).upsert(log);
  }

  setAmount(String containerId, int amount) {
    var item = ref.read(currentItemNotifierProvider)!;
    var current = ref
        .read(allAssignmentsNotifierProvider.notifier)
        .byIds(item.id, containerId);

    if (current != null) {
      ref
          .read(assignmentDataProvider.notifier)
          .upsertOrDelete(current.copyWith(count: amount));
      var log = _buildEntry(item, containerId, amount - current.count);
      ref.read(workLogDataProvider.notifier).upsert(log);
    } else if (amount > 0) {
      // Create new assignment if none exists and amount > 0
      var assignment = Assignment(
        id: uuid.v4(),
        itemId: item.id,
        containerId: containerId,
        count: amount,
      );
      ref.read(assignmentDataProvider.notifier).upsertOrDelete(assignment);
      var log = _buildEntry(item, containerId, amount);
      ref.read(workLogDataProvider.notifier).upsert(log);
    }
  }

  _buildEntry(Item item, String containerId, int count) => LogEntry(
    id: uuid.v4(),
    itemId: item.id,
    containerId: containerId,
    count: count,
    date: DateTime.now(),
    user: Auth().currentUserName ?? "Unknown",
  );
}
