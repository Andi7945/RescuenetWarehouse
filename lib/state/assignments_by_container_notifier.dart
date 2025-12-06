import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'assignments_by_container_notifier.g.dart';

/// Watches assignments for a specific container.
/// Only rebuilds when assignments for THIS container change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
/// ```
@riverpod
class AssignmentsByContainer extends _$AssignmentsByContainer {
  @override
  Stream<List<Assignment>> build(String containerId) {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignmentsByContainer(containerId);
  }

  /// Get total count of assignments for this container
  int getTotalCount() {
    final assignments = state.valueOrNull ?? [];
    return assignments.fold(0, (sum, a) => sum + a.count);
  }
}
