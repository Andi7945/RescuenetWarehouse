import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/item.dart';
import '../models/container_dao.dart';
import '../models/assignment.dart';
import '../repositories/repository_providers.dart';

part 'data_operations_notifier.g.dart';

/// Enumeration of all supported CRUD operations.
/// Used to track loading states for different types of operations.
enum DataOperation {
  // Item operations
  itemCreate,
  itemUpdate,
  itemDelete,
  itemBatchUpdate,
  
  // Container operations
  containerCreate,
  containerUpdate,
  containerDelete,
  containerBatchUpdate,
  
  // Assignment operations
  assignmentCreate,
  assignmentUpdate,
  assignmentDelete,
  assignmentBatchUpdate,
  assignmentBatchDelete,
}

/// State class to track multiple concurrent operations.
/// Maintains a map of operation types to their AsyncValue states.
class DataOperationsState {
  const DataOperationsState({
    this.operations = const {},
  });

  final Map<DataOperation, AsyncValue<void>> operations;

  /// Check if any operation is currently loading.
  bool get hasLoadingOperations => operations.values.any(
    (state) => state.isLoading,
  );

  /// Check if a specific operation is loading.
  bool isLoading(DataOperation operation) => 
    operations[operation]?.isLoading ?? false;

  /// Get the error for a specific operation, if any.
  Object? getError(DataOperation operation) =>
    operations[operation]?.error;

  /// Check if a specific operation has an error.
  bool hasError(DataOperation operation) =>
    operations[operation]?.hasError ?? false;

  /// Copy the state with updated operation status.
  DataOperationsState copyWithOperation(
    DataOperation operation,
    AsyncValue<void> state,
  ) {
    return DataOperationsState(
      operations: {
        ...operations,
        operation: state,
      },
    );
  }

  /// Clear the state for a specific operation.
  DataOperationsState clearOperation(DataOperation operation) {
    final newOperations = {...operations};
    newOperations.remove(operation);
    return DataOperationsState(operations: newOperations);
  }

  /// Clear all operation states.
  DataOperationsState clearAll() {
    return const DataOperationsState();
  }
}

/// Notifier for managing CRUD operation loading states.
/// 
/// This notifier provides a centralized way to track loading states for all
/// CRUD operations across Items, Containers, and Assignments. It follows the
/// same pattern as AuthNotifier but extends it to handle multiple concurrent
/// operations with proper error handling.
/// 
/// Usage:
/// ```dart
/// // Check if item creation is loading
/// final isLoading = ref.watch(dataOperationsNotifierProvider
///   .select((state) => state.isLoading(DataOperation.itemCreate)));
/// 
/// // Perform an item operation
/// await ref.read(dataOperationsNotifierProvider.notifier)
///   .createItem(newItem);
/// ```
@riverpod
class DataOperationsNotifier extends _$DataOperationsNotifier {
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
  // ITEM OPERATIONS
  // ============================================================================

  /// Create a new item.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> createItem(Item item) async {
    _setOperationState(DataOperation.itemCreate, const AsyncValue.loading());

    try {
      final repository = ref.read(itemRepositoryProvider);
      await repository.upsertItem(item);
      _setOperationState(DataOperation.itemCreate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.itemCreate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Update an existing item.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> updateItem(Item item) async {
    _setOperationState(DataOperation.itemUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(itemRepositoryProvider);
      await repository.upsertItem(item);
      _setOperationState(DataOperation.itemUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.itemUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Delete an item by ID.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> deleteItem(String itemId) async {
    _setOperationState(DataOperation.itemDelete, const AsyncValue.loading());

    try {
      final repository = ref.read(itemRepositoryProvider);
      await repository.deleteItem(itemId);
      _setOperationState(DataOperation.itemDelete, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.itemDelete,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Batch update multiple items.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> batchUpdateItems(List<Item> items) async {
    _setOperationState(DataOperation.itemBatchUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(itemRepositoryProvider);
      await repository.batchUpdateItems(items);
      _setOperationState(DataOperation.itemBatchUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.itemBatchUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  // ============================================================================
  // CONTAINER OPERATIONS
  // ============================================================================

  /// Create a new container.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> createContainer(ContainerDao container) async {
    _setOperationState(DataOperation.containerCreate, const AsyncValue.loading());

    try {
      final repository = ref.read(containerRepositoryProvider);
      await repository.createContainer(container);
      _setOperationState(DataOperation.containerCreate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.containerCreate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Update an existing container.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> updateContainer(ContainerDao container) async {
    _setOperationState(DataOperation.containerUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(containerRepositoryProvider);
      await repository.updateContainer(container);
      _setOperationState(DataOperation.containerUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.containerUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Delete a container by ID.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> deleteContainer(String containerId) async {
    _setOperationState(DataOperation.containerDelete, const AsyncValue.loading());

    try {
      final repository = ref.read(containerRepositoryProvider);
      await repository.deleteContainer(containerId);
      _setOperationState(DataOperation.containerDelete, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.containerDelete,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Batch update multiple containers.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> batchUpdateContainers(List<ContainerDao> containers) async {
    _setOperationState(DataOperation.containerBatchUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(containerRepositoryProvider);
      await repository.batchUpdateContainers(containers);
      _setOperationState(DataOperation.containerBatchUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.containerBatchUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  // ============================================================================
  // ASSIGNMENT OPERATIONS
  // ============================================================================

  /// Create a new assignment.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> createAssignment(Assignment assignment) async {
    _setOperationState(DataOperation.assignmentCreate, const AsyncValue.loading());

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.upsertAssignment(assignment);
      _setOperationState(DataOperation.assignmentCreate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.assignmentCreate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Update an existing assignment.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> updateAssignment(Assignment assignment) async {
    _setOperationState(DataOperation.assignmentUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.upsertAssignment(assignment);
      _setOperationState(DataOperation.assignmentUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.assignmentUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Delete an assignment by ID.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> deleteAssignment(String assignmentId) async {
    _setOperationState(DataOperation.assignmentDelete, const AsyncValue.loading());

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.deleteAssignment(assignmentId);
      _setOperationState(DataOperation.assignmentDelete, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.assignmentDelete,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Upsert or delete assignment based on count.
  /// Uses the repository's business logic to determine create/update/delete.
  Future<void> upsertOrDeleteAssignment(Assignment assignment) async {
    _setOperationState(DataOperation.assignmentUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.upsertOrDeleteAssignment(assignment);
      _setOperationState(DataOperation.assignmentUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.assignmentUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Batch update multiple assignments.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> batchUpdateAssignments(List<Assignment> assignments) async {
    _setOperationState(DataOperation.assignmentBatchUpdate, const AsyncValue.loading());

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.batchUpdateAssignments(assignments);
      _setOperationState(DataOperation.assignmentBatchUpdate, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.assignmentBatchUpdate,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }

  /// Batch delete multiple assignments.
  /// Sets loading state during the operation and handles errors appropriately.
  Future<void> batchDeleteAssignments(List<String> assignmentIds) async {
    _setOperationState(DataOperation.assignmentBatchDelete, const AsyncValue.loading());

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.batchDeleteAssignments(assignmentIds);
      _setOperationState(DataOperation.assignmentBatchDelete, const AsyncValue.data(null));
    } catch (error, stackTrace) {
      _setOperationState(
        DataOperation.assignmentBatchDelete,
        AsyncValue.error(error, stackTrace),
      );
      rethrow;
    }
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Convenience provider to check if any operation is currently loading.
@riverpod
bool isAnyOperationLoading(IsAnyOperationLoadingRef ref) {
  final state = ref.watch(dataOperationsNotifierProvider);
  return state.hasLoadingOperations;
}

/// Convenience provider to check if a specific operation is loading.
@riverpod
bool isOperationLoading(IsOperationLoadingRef ref, DataOperation operation) {
  final state = ref.watch(dataOperationsNotifierProvider);
  return state.isLoading(operation);
}

/// Convenience provider to get the error for a specific operation.
@riverpod
Object? getOperationError(GetOperationErrorRef ref, DataOperation operation) {
  final state = ref.watch(dataOperationsNotifierProvider);
  return state.getError(operation);
}

/// Convenience provider to check if a specific operation has an error.
@riverpod
bool hasOperationError(HasOperationErrorRef ref, DataOperation operation) {
  final state = ref.watch(dataOperationsNotifierProvider);
  return state.hasError(operation);
}