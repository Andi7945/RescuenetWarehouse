import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'assignments_by_item_notifier.g.dart';

/// Watches assignments for a specific item.
/// Only rebuilds when assignments for THIS item change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByItemProvider(itemId));
/// ```
@riverpod
class AssignmentsByItem extends _$AssignmentsByItem {
  @override
  Stream<List<Assignment>> build(String itemId) {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignmentsByItem(itemId);
  }

  /// Get total count of this item across all containers
  int getTotalAssigned() {
    final assignments = state.valueOrNull ?? [];
    return assignments.fold(0, (sum, a) => sum + a.count);
  }
}
