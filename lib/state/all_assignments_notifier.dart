import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/assignment_data.dart';
import '../models/assignment.dart';

import 'package:collection/collection.dart';

part 'all_assignments_notifier.g.dart';

@riverpod
class AllAssignmentsNotifier extends _$AllAssignmentsNotifier {
  @override
  List<Assignment> build() {
    return ref.watch(assignmentDataProvider);
  }

  Assignment? byIds(String itemId, String containerId) {
    return state.firstWhereOrNull(
        (a) => a.containerId == containerId && a.itemId == itemId);
  }

  List<Assignment> byItemAndContainers(
      String itemId, List<String> containerIds) {
    return state
        .where(
            (a) => containerIds.contains(a.containerId) && a.itemId == itemId)
        .toList();
  }

  List<Assignment> byContainer(String containerId) {
    return state.where((a) => a.containerId == containerId).toList();
  }

  List<Assignment> byItem(String itemId) {
    return state.where((a) => a.itemId == itemId).toList();
  }
}
