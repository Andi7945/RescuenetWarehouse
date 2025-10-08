import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assignment_by_container_state.g.dart';

@riverpod
class AssignmentByContainerState extends _$AssignmentByContainerState {
  @override
  Map<Item, Assignment> build(String containerId) {
    var assignmentsAsync = ref.watch(allAssignmentsAsyncProvider);

    return assignmentsAsync.when(
      data: (assignments) {
        var containerAssignments = assignments
            .where((a) => a.containerId == containerId);

        var assignedItems = Map.fromEntries(
          containerAssignments.map((a) {
            var i = ref.read(allItemsNotifierProvider.notifier).byId(a.itemId);
            if (i != null && a.count > 0) {
              return MapEntry(i, a);
            }
          }).nonNulls,
        );
        return assignedItems;
      },
      loading: () => <Item, Assignment>{},
      error: (_, __) => <Item, Assignment>{},
    );
  }

  Future<void> addItem(String containerId, Item item) async {
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
    
    // Use DataOperationsNotifier for proper loading states
    await ref.read(dataOperationsNotifierProvider.notifier).createAssignment(assignment);
  }

  Future<void> upsert(Assignment assignment) async {
    // Use DataOperationsNotifier for proper loading states
    await ref.read(dataOperationsNotifierProvider.notifier).upsertOrDeleteAssignment(assignment);
  }
}

/// AsyncValue-based assignment by container state provider for loading states support.
/// 
/// This provider wraps the container assignment data in AsyncValue to provide proper
/// loading, error, and data states for UI components during assignment operations.
/// 
/// Usage:
/// ```dart
/// AsyncValueBuilder<Map<Item, Assignment>>(
///   value: ref.watch(assignmentByContainerAsyncProvider(containerId)),
///   data: (assignedItems) => AssignmentsList(assignedItems: assignedItems),
/// )
/// ```
@riverpod
class AssignmentByContainerAsync extends _$AssignmentByContainerAsync {
  @override
  Stream<Map<Item, Assignment>> build(String containerId) {
    // Watch both assignments and items as streams
    final assignmentsStream = ref.watch(allAssignmentsAsyncProvider.future);
    final itemsStream = ref.watch(allItemsAsyncProvider.future);
    
    return Stream.fromFuture(
      Future.wait([assignmentsStream, itemsStream]).then((results) {
        final allAssignments = results[0] as List<Assignment>;
        final allItems = results[1] as List<Item>;
        
        // Filter assignments for this container
        var containerAssignments = allAssignments
            .where((a) => a.containerId == containerId);

        var assignedItems = <Item, Assignment>{};
        for (var assignment in containerAssignments) {
          if (assignment.count > 0) {
            try {
              var item = allItems.firstWhere((i) => i.id == assignment.itemId);
              assignedItems[item] = assignment;
            } catch (e) {
              // Item not found - skip this assignment (this should not happen in normal operation)
              // Using debugPrint to avoid production warnings  
              // debugPrint('Warning: Item with ID ${assignment.itemId} not found for container $containerId');
            }
          }
        }
        
        return assignedItems;
      })
    );
  }

  /// Add item to container assignments (async version)
  Future<void> addItem(String containerId, Item item) async {
    final currentAssignments = state.valueOrNull ?? {};
    
    if (currentAssignments.keys.map((i) => i.id).contains(item.id)) {
      // Assignment for item already exists. Doing nothing.
      return;
    }
    
    var assignment = Assignment(
      id: uuid.v4(),
      itemId: item.id,
      containerId: containerId,
      count: 1,
    );
    
    // Use DataOperationsNotifier for proper loading states
    await ref.read(dataOperationsNotifierProvider.notifier).createAssignment(assignment);
  }

  /// Update/delete assignment (async version)
  Future<void> upsert(Assignment assignment) async {
    // Use DataOperationsNotifier for proper loading states
    await ref.read(dataOperationsNotifierProvider.notifier).upsertOrDeleteAssignment(assignment);
  }

  /// Refresh the assignment data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
