import 'package:rescuenet_warehouse/db/assignment_data.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assignment_by_container_state.g.dart';

@riverpod
class AssignmentByContainerState extends _$AssignmentByContainerState {
  @override
  Map<Item, Assignment> build(String containerId) {
    var assignments = ref
        .watch(assignmentDataProvider)
        .where((a) => a.containerId == containerId);

    var assignedItems = Map.fromEntries(
      assignments.map((a) {
        var i = ref.read(allItemsNotifierProvider.notifier).byId(a.itemId);
        if (i != null && a.count > 0) {
          return MapEntry(i, a);
        }
      }).nonNulls,
    );
    return assignedItems;
  }

  addItem(String containerId, Item item) {
    if (state.keys.map((i) => i.id).contains(item.id)) {
      print("Assignment for item already exists. Doing nothing");
      return;
    }
    var assignment = Assignment(
      id: uuid.v4(),
      itemId: item.id,
      containerId: containerId,
      count: 1,
    );
    ref.read(assignmentDataProvider.notifier).upsertOrDelete(assignment);
  }

  upsert(Assignment assignment) {
    ref.read(assignmentDataProvider.notifier).upsertOrDelete(assignment);
  }
}
