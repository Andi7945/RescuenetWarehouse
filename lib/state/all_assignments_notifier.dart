import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

import '../models/assignment.dart';

import 'package:collection/collection.dart';

part 'all_assignments_notifier.g.dart';

@riverpod
class AllAssignmentsNotifier extends _$AllAssignmentsNotifier {
  @override
  List<Assignment> build() {
    final repository = ref.watch(assignmentRepositoryProvider);
    
    // Use proper stream subscription management
    final subscription = repository.watchAssignments().listen((assignments) {
      state = assignments;
    });
    
    // Dispose subscription when notifier is disposed
    ref.onDispose(() {
      subscription.cancel();
    });
    
    return [];
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

/// Stream-based provider for backward compatibility.
/// This maintains the existing Stream<List<Assignment>> pattern that other
/// parts of the app may depend on.
@riverpod
Stream<List<Assignment>> allAssignmentsStream(AllAssignmentsStreamRef ref) {
  final repository = ref.watch(assignmentRepositoryProvider);
  return repository.watchAssignments();
}

/// AsyncValue-based assignments provider for loading states support.
/// 
/// This provider wraps the assignments stream in AsyncValue to provide proper
/// loading, error, and data states for UI components. It follows the enhanced
/// pattern from LOADING_INDICATORS_DESIGN.md while maintaining compatibility
/// with the existing AllAssignmentsNotifier.
/// 
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Assignment>>(
///   value: ref.watch(allAssignmentsAsyncProvider),
///   data: (assignments) => AssignmentsList(assignments: assignments),
/// )
/// ```
@riverpod
class AllAssignmentsAsync extends _$AllAssignmentsAsync {
  @override
  Stream<List<Assignment>> build() {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignments();
  }

  /// Get assignment by item and container IDs from the current async state
  Assignment? byIds(String itemId, String containerId) {
    return state.valueOrNull?.firstWhereOrNull(
        (a) => a.containerId == containerId && a.itemId == itemId);
  }

  /// Get assignments by item ID and multiple container IDs from the current async state
  List<Assignment> byItemAndContainers(String itemId, List<String> containerIds) {
    final assignments = state.valueOrNull;
    if (assignments == null) return [];
    return assignments
        .where((a) => containerIds.contains(a.containerId) && a.itemId == itemId)
        .toList();
  }

  /// Get assignments by container ID from the current async state
  List<Assignment> byContainer(String containerId) {
    final assignments = state.valueOrNull;
    if (assignments == null) return [];
    return assignments.where((a) => a.containerId == containerId).toList();
  }

  /// Get assignments by item ID from the current async state
  List<Assignment> byItem(String itemId) {
    final assignments = state.valueOrNull;
    if (assignments == null) return [];
    return assignments.where((a) => a.itemId == itemId).toList();
  }

  /// Refresh the assignments data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
