import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/item.dart';
import '../models/container_dao.dart';
import '../models/assignment.dart';
import '../repositories/repository_providers.dart';
import '../widgets/loading/debounced_loading_system.dart';
import 'data_operations_notifier.dart';

part 'debounced_data_operations_notifier.g.dart';

/// Enhanced notifier that combines DataOperationsNotifier with debounced loading
///
/// This provides the same functionality as DataOperationsNotifier but with
/// intelligent loading state management that prevents loading flashes for
/// fast operations while maintaining proper feedback for longer operations.
@riverpod
class DebouncedDataOperationsNotifier extends _$DebouncedDataOperationsNotifier {
  @override
  DataOperationsState build() {
    return const DataOperationsState();
  }

  /// Set the state for a specific operation.
  void _setOperationState(DataOperation operation, AsyncValue<void> operationState) {
    state = state.copyWithOperation(operation, operationState);
  }

  /// Clear the state for a specific operation.
  void clearOperation(DataOperation operation) {
    state = state.clearOperation(operation);
  }

  /// Clear all operation states.
  void clearAll() {
    state = state.clearAll();
  }

  // ============================================================================
  // ITEM OPERATIONS WITH DEBOUNCED LOADING
  // ============================================================================

  /// Create a new item with debounced loading for UI feedback
  Future<void> createItem(Item item, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.medium,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.itemCreate,
      debouncedOperationKey: debouncedOperationKey ?? 'item_create_${item.id}',
      config: config,
      task: () async {
        final repository = ref.read(itemRepositoryProvider);
        await repository.upsertItem(item);
      },
    );
  }

  /// Update an existing item with debounced loading for UI feedback
  Future<void> updateItem(Item item, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.quick,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.itemUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'item_update_${item.id}',
      config: config,
      task: () async {
        final repository = ref.read(itemRepositoryProvider);
        await repository.upsertItem(item);
      },
    );
  }

  /// Delete an item with debounced loading for UI feedback
  Future<void> deleteItem(String itemId, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.medium,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.itemDelete,
      debouncedOperationKey: debouncedOperationKey ?? 'item_delete_$itemId',
      config: config,
      task: () async {
        final repository = ref.read(itemRepositoryProvider);
        await repository.deleteItem(itemId);
      },
    );
  }

  /// Batch update multiple items with debounced loading for UI feedback
  Future<void> batchUpdateItems(List<Item> items, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.slow,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.itemBatchUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'item_batch_update_${items.length}',
      config: config,
      task: () async {
        final repository = ref.read(itemRepositoryProvider);
        await repository.batchUpdateItems(items);
      },
    );
  }

  // ============================================================================
  // CONTAINER OPERATIONS WITH DEBOUNCED LOADING
  // ============================================================================

  /// Create a new container with debounced loading for UI feedback
  Future<void> createContainer(ContainerDao container, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.medium,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.containerCreate,
      debouncedOperationKey: debouncedOperationKey ?? 'container_create_${container.id}',
      config: config,
      task: () async {
        final repository = ref.read(containerRepositoryProvider);
        await repository.createContainer(container);
      },
    );
  }

  /// Update an existing container with debounced loading for UI feedback
  Future<void> updateContainer(ContainerDao container, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.quick,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.containerUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'container_update_${container.id}',
      config: config,
      task: () async {
        final repository = ref.read(containerRepositoryProvider);
        await repository.updateContainer(container);
      },
    );
  }

  /// Delete a container with debounced loading for UI feedback
  Future<void> deleteContainer(String containerId, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.medium,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.containerDelete,
      debouncedOperationKey: debouncedOperationKey ?? 'container_delete_$containerId',
      config: config,
      task: () async {
        final repository = ref.read(containerRepositoryProvider);
        await repository.deleteContainer(containerId);
      },
    );
  }

  /// Batch update multiple containers with debounced loading for UI feedback
  Future<void> batchUpdateContainers(List<ContainerDao> containers, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.slow,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.containerBatchUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'container_batch_update_${containers.length}',
      config: config,
      task: () async {
        final repository = ref.read(containerRepositoryProvider);
        await repository.batchUpdateContainers(containers);
      },
    );
  }

  // ============================================================================
  // ASSIGNMENT OPERATIONS WITH DEBOUNCED LOADING
  // ============================================================================

  /// Create a new assignment with debounced loading for UI feedback
  Future<void> createAssignment(Assignment assignment, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.quick,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.assignmentCreate,
      debouncedOperationKey: debouncedOperationKey ?? 'assignment_create_${assignment.id}',
      config: config,
      task: () async {
        final repository = ref.read(assignmentRepositoryProvider);
        await repository.upsertAssignment(assignment);
      },
    );
  }

  /// Update an existing assignment with debounced loading for UI feedback
  Future<void> updateAssignment(Assignment assignment, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.quick,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.assignmentUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'assignment_update_${assignment.id}',
      config: config,
      task: () async {
        final repository = ref.read(assignmentRepositoryProvider);
        await repository.upsertAssignment(assignment);
      },
    );
  }

  /// Delete an assignment with debounced loading for UI feedback
  Future<void> deleteAssignment(String assignmentId, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.quick,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.assignmentDelete,
      debouncedOperationKey: debouncedOperationKey ?? 'assignment_delete_$assignmentId',
      config: config,
      task: () async {
        final repository = ref.read(assignmentRepositoryProvider);
        await repository.deleteAssignment(assignmentId);
      },
    );
  }

  /// Upsert or delete assignment based on count with debounced loading
  Future<void> upsertOrDeleteAssignment(Assignment assignment, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.quick,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.assignmentUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'assignment_upsert_${assignment.id}',
      config: config,
      task: () async {
        final repository = ref.read(assignmentRepositoryProvider);
        await repository.upsertOrDeleteAssignment(assignment);
      },
    );
  }

  /// Batch update multiple assignments with debounced loading for UI feedback
  Future<void> batchUpdateAssignments(List<Assignment> assignments, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.slow,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.assignmentBatchUpdate,
      debouncedOperationKey: debouncedOperationKey ?? 'assignment_batch_update_${assignments.length}',
      config: config,
      task: () async {
        final repository = ref.read(assignmentRepositoryProvider);
        await repository.batchUpdateAssignments(assignments);
      },
    );
  }

  /// Batch delete multiple assignments with debounced loading for UI feedback
  Future<void> batchDeleteAssignments(List<String> assignmentIds, {
    String? debouncedOperationKey,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.medium,
  }) async {
    return _executeWithDebouncedLoading(
      operation: DataOperation.assignmentBatchDelete,
      debouncedOperationKey: debouncedOperationKey ?? 'assignment_batch_delete_${assignmentIds.length}',
      config: config,
      task: () async {
        final repository = ref.read(assignmentRepositoryProvider);
        await repository.batchDeleteAssignments(assignmentIds);
      },
    );
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Execute an operation with both DataOperationsNotifier state and debounced loading
  Future<void> _executeWithDebouncedLoading({
    required DataOperation operation,
    required String debouncedOperationKey,
    required DebouncedLoadingConfig config,
    required Future<void> Function() task,
  }) async {
    // Get the appropriate debounced provider based on config
    final provider = _getDebouncedProvider(debouncedOperationKey, config);
    final debouncedNotifier = ref.read(provider.notifier);

    // Set loading state in DataOperationsNotifier
    _setOperationState(operation, const AsyncValue.loading());

    // Start debounced loading
    debouncedNotifier.startOperation();

    try {
      // Execute the actual task
      await task();

      // Set success state
      _setOperationState(operation, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      // Set error state
      _setOperationState(
        operation,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    } finally {
      // Complete debounced loading
      debouncedNotifier.completeOperation();
    }
  }

  /// Get the appropriate debounced provider based on configuration
  StateNotifierProvider<DebouncedLoadingNotifier, DebouncedLoadingState> _getDebouncedProvider(
    String operationKey,
    DebouncedLoadingConfig config,
  ) {
    if (config == DebouncedLoadingConfig.quick) {
      return quickOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.medium) {
      return mediumOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.slow) {
      return slowOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.immediate) {
      return immediateOperationLoadingProvider(operationKey);
    }
    return debouncedLoadingProvider(operationKey);
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS FOR DEBOUNCED OPERATIONS
// ============================================================================

/// Convenience provider to check if any operation is currently loading (with debouncing)
@riverpod
bool isAnyDebouncedOperationLoading(IsAnyDebouncedOperationLoadingRef ref) {
  final state = ref.watch(debouncedDataOperationsNotifierProvider);
  return state.hasLoadingOperations;
}

/// Convenience provider to check if a specific operation is loading (with debouncing)
@riverpod
bool isDebouncedOperationLoading(IsDebouncedOperationLoadingRef ref, DataOperation operation) {
  final state = ref.watch(debouncedDataOperationsNotifierProvider);
  return state.isLoading(operation);
}

/// Convenience provider to get the error for a specific operation (with debouncing)
@riverpod
Object? getDebouncedOperationError(GetDebouncedOperationErrorRef ref, DataOperation operation) {
  final state = ref.watch(debouncedDataOperationsNotifierProvider);
  return state.getError(operation);
}

/// Convenience provider to check if a specific operation has an error (with debouncing)
@riverpod
bool hasDebouncedOperationError(HasDebouncedOperationErrorRef ref, DataOperation operation) {
  final state = ref.watch(debouncedDataOperationsNotifierProvider);
  return state.hasError(operation);
}
