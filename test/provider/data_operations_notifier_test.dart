import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import '../helpers/test_helpers.dart';

/// Test file for DataOperationsNotifier
/// 
/// This file tests the DataOperationsNotifier created in Step 1.2, ensuring
/// it properly manages loading states for CRUD operations and integrates
/// correctly with repositories.
void main() {
  group('DataOperationsNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Set up test environment with mock repositories
      container = createTestProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('starts with empty operations state', () {
        final state = container.read(dataOperationsNotifierProvider);
        
        expect(state.operations.isEmpty, isTrue);
        expect(state.hasLoadingOperations, isFalse);
      });

      test('convenience providers return correct initial values', () {
        expect(
          container.read(isAnyOperationLoadingProvider),
          isFalse,
        );
        expect(
          container.read(isOperationLoadingProvider(DataOperation.itemCreate)),
          isFalse,
        );
        expect(
          container.read(getOperationErrorProvider(DataOperation.itemCreate)),
          isNull,
        );
        expect(
          container.read(hasOperationErrorProvider(DataOperation.itemCreate)),
          isFalse,
        );
      });
    });

    group('DataOperationsState', () {
      test('tracks loading operations correctly', () {
        final state = DataOperationsState(
          operations: {
            DataOperation.itemCreate: const AsyncValue.loading(),
            DataOperation.containerUpdate: const AsyncValue.data(null),
          },
        );

        expect(state.hasLoadingOperations, isTrue);
        expect(state.isLoading(DataOperation.itemCreate), isTrue);
        expect(state.isLoading(DataOperation.containerUpdate), isFalse);
        expect(state.isLoading(DataOperation.itemDelete), isFalse);
      });

      test('tracks error states correctly', () {
        final error = Exception('Test error');
        final state = DataOperationsState(
          operations: {
            DataOperation.itemCreate: AsyncValue.error(error, StackTrace.current),
            DataOperation.containerUpdate: const AsyncValue.data(null),
          },
        );

        expect(state.hasError(DataOperation.itemCreate), isTrue);
        expect(state.hasError(DataOperation.containerUpdate), isFalse);
        expect(state.getError(DataOperation.itemCreate), equals(error));
        expect(state.getError(DataOperation.containerUpdate), isNull);
      });

      test('copyWithOperation creates new state correctly', () {
        final initialState = const DataOperationsState();
        final loadingState = initialState.copyWithOperation(
          DataOperation.itemCreate,
          const AsyncValue.loading(),
        );

        expect(loadingState.isLoading(DataOperation.itemCreate), isTrue);
        expect(initialState.isLoading(DataOperation.itemCreate), isFalse);
      });

      test('clearOperation removes operation from state', () {
        final state = DataOperationsState(
          operations: {
            DataOperation.itemCreate: const AsyncValue.loading(),
            DataOperation.containerUpdate: const AsyncValue.data(null),
          },
        );

        final clearedState = state.clearOperation(DataOperation.itemCreate);
        
        expect(clearedState.operations.containsKey(DataOperation.itemCreate), isFalse);
        expect(clearedState.operations.containsKey(DataOperation.containerUpdate), isTrue);
      });

      test('clearAll removes all operations', () {
        final state = DataOperationsState(
          operations: {
            DataOperation.itemCreate: const AsyncValue.loading(),
            DataOperation.containerUpdate: const AsyncValue.data(null),
          },
        );

        final clearedState = state.clearAll();
        
        expect(clearedState.operations.isEmpty, isTrue);
      });
    });

    group('Item Operations', () {
      test('createItem sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItem = createTestItem();

        // Start the operation (don't await yet)
        final future = notifier.createItem(testItem);

        // Check that loading state is set immediately
        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.itemCreate),
          isTrue,
        );

        // Wait for completion
        await future;

        // Check that operation completed successfully
        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.itemCreate), isFalse);
        expect(finalState.hasError(DataOperation.itemCreate), isFalse);
      });

      test('updateItem sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItem = createTestItem();

        final future = notifier.updateItem(testItem);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.itemUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.itemUpdate), isFalse);
        expect(finalState.hasError(DataOperation.itemUpdate), isFalse);
      });

      test('deleteItem sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);

        final future = notifier.deleteItem('test-item-id');

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.itemDelete),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.itemDelete), isFalse);
        expect(finalState.hasError(DataOperation.itemDelete), isFalse);
      });

      test('batchUpdateItems sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItems = [createTestItem(), createTestItem(id: 'item2')];

        final future = notifier.batchUpdateItems(testItems);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.itemBatchUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.itemBatchUpdate), isFalse);
        expect(finalState.hasError(DataOperation.itemBatchUpdate), isFalse);
      });

      test('createItem handles errors correctly', () async {
        // Override repository to throw error
        final errorContainer = createTestProviderContainer(
          overrides: [
            itemRepositoryProvider.overrideWith((ref) => ThrowingMockItemRepository()),
          ],
        );

        final notifier = errorContainer.read(dataOperationsNotifierProvider.notifier);
        final testItem = createTestItem();

        try {
          await notifier.createItem(testItem);
          fail('Expected exception was not thrown');
        } catch (e) {
          // Error should be rethrown
          expect(e, isA<Exception>());
        }

        // Check error state
        final finalState = errorContainer.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.itemCreate), isFalse);
        expect(finalState.hasError(DataOperation.itemCreate), isTrue);
        expect(finalState.getError(DataOperation.itemCreate), isA<Exception>());

        errorContainer.dispose();
      });
    });

    group('Container Operations', () {
      test('createContainer sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testContainer = createTestContainer();

        final future = notifier.createContainer(testContainer);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.containerCreate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.containerCreate), isFalse);
        expect(finalState.hasError(DataOperation.containerCreate), isFalse);
      });

      test('updateContainer sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testContainer = createTestContainer();

        final future = notifier.updateContainer(testContainer);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.containerUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.containerUpdate), isFalse);
        expect(finalState.hasError(DataOperation.containerUpdate), isFalse);
      });

      test('deleteContainer sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);

        final future = notifier.deleteContainer('test-container-id');

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.containerDelete),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.containerDelete), isFalse);
        expect(finalState.hasError(DataOperation.containerDelete), isFalse);
      });

      test('batchUpdateContainers sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testContainers = [createTestContainer(), createTestContainer(id: 'container2')];

        final future = notifier.batchUpdateContainers(testContainers);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.containerBatchUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.containerBatchUpdate), isFalse);
        expect(finalState.hasError(DataOperation.containerBatchUpdate), isFalse);
      });
    });

    group('Assignment Operations', () {
      test('createAssignment sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testAssignment = createTestAssignment();

        final future = notifier.createAssignment(testAssignment);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentCreate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.assignmentCreate), isFalse);
        expect(finalState.hasError(DataOperation.assignmentCreate), isFalse);
      });

      test('updateAssignment sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testAssignment = createTestAssignment();

        final future = notifier.updateAssignment(testAssignment);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.assignmentUpdate), isFalse);
        expect(finalState.hasError(DataOperation.assignmentUpdate), isFalse);
      });

      test('deleteAssignment sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);

        final future = notifier.deleteAssignment('test-assignment-id');

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentDelete),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.assignmentDelete), isFalse);
        expect(finalState.hasError(DataOperation.assignmentDelete), isFalse);
      });

      test('upsertOrDeleteAssignment sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testAssignment = createTestAssignment();

        final future = notifier.upsertOrDeleteAssignment(testAssignment);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.assignmentUpdate), isFalse);
        expect(finalState.hasError(DataOperation.assignmentUpdate), isFalse);
      });

      test('batchUpdateAssignments sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testAssignments = [createTestAssignment(), createTestAssignment(id: 'assignment2')];

        final future = notifier.batchUpdateAssignments(testAssignments);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentBatchUpdate),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.assignmentBatchUpdate), isFalse);
        expect(finalState.hasError(DataOperation.assignmentBatchUpdate), isFalse);
      });

      test('batchDeleteAssignments sets loading state and calls repository', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final assignmentIds = ['assignment1', 'assignment2'];

        final future = notifier.batchDeleteAssignments(assignmentIds);

        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentBatchDelete),
          isTrue,
        );

        await future;

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.assignmentBatchDelete), isFalse);
        expect(finalState.hasError(DataOperation.assignmentBatchDelete), isFalse);
      });
    });

    group('Operation Management', () {
      test('clearOperation removes specific operation state', () {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        
        // Set some operation states manually
        notifier.state = notifier.state.copyWithOperation(
          DataOperation.itemCreate,
          const AsyncValue.loading(),
        );
        notifier.state = notifier.state.copyWithOperation(
          DataOperation.containerUpdate,
          const AsyncValue.data(null),
        );

        // Clear one operation
        notifier.clearOperation(DataOperation.itemCreate);

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.operations.containsKey(DataOperation.itemCreate), isFalse);
        expect(finalState.operations.containsKey(DataOperation.containerUpdate), isTrue);
      });

      test('clearAll removes all operation states', () {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        
        // Set some operation states manually
        notifier.state = notifier.state.copyWithOperation(
          DataOperation.itemCreate,
          const AsyncValue.loading(),
        );
        notifier.state = notifier.state.copyWithOperation(
          DataOperation.containerUpdate,
          const AsyncValue.data(null),
        );

        // Clear all operations
        notifier.clearAll();

        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.operations.isEmpty, isTrue);
      });
    });

    group('Convenience Providers', () {
      test('isAnyOperationLoading tracks global loading state', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        
        // Initially no operations loading
        expect(container.read(isAnyOperationLoadingProvider), isFalse);

        // Start an operation
        final future = notifier.createItem(createTestItem());
        
        // Should be loading
        expect(container.read(isAnyOperationLoadingProvider), isTrue);

        // Complete operation
        await future;
        
        // Should no longer be loading
        expect(container.read(isAnyOperationLoadingProvider), isFalse);
      });

      test('isOperationLoading tracks specific operation state', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        
        // Initially not loading
        expect(
          container.read(isOperationLoadingProvider(DataOperation.itemCreate)),
          isFalse,
        );

        // Start item creation
        final itemFuture = notifier.createItem(createTestItem());
        
        // Item creation should be loading, container creation should not
        expect(
          container.read(isOperationLoadingProvider(DataOperation.itemCreate)),
          isTrue,
        );
        expect(
          container.read(isOperationLoadingProvider(DataOperation.containerCreate)),
          isFalse,
        );

        await itemFuture;
        
        // Should no longer be loading
        expect(
          container.read(isOperationLoadingProvider(DataOperation.itemCreate)),
          isFalse,
        );
      });

      test('getOperationError returns error for failed operations', () async {
        // Use container with throwing repository
        final errorContainer = createTestProviderContainer(
          overrides: [
            itemRepositoryProvider.overrideWith((ref) => ThrowingMockItemRepository()),
          ],
        );

        final notifier = errorContainer.read(dataOperationsNotifierProvider.notifier);
        
        // Initially no error
        expect(
          errorContainer.read(getOperationErrorProvider(DataOperation.itemCreate)),
          isNull,
        );

        try {
          await notifier.createItem(createTestItem());
        } catch (e) {
          // Expected error
        }
        
        // Should have error
        final error = errorContainer.read(getOperationErrorProvider(DataOperation.itemCreate));
        expect(error, isNotNull);
        expect(error, isA<Exception>());

        errorContainer.dispose();
      });

      test('hasOperationError tracks error state', () async {
        // Use container with throwing repository
        final errorContainer = createTestProviderContainer(
          overrides: [
            itemRepositoryProvider.overrideWith((ref) => ThrowingMockItemRepository()),
          ],
        );

        final notifier = errorContainer.read(dataOperationsNotifierProvider.notifier);
        
        // Initially no error
        expect(
          errorContainer.read(hasOperationErrorProvider(DataOperation.itemCreate)),
          isFalse,
        );

        try {
          await notifier.createItem(createTestItem());
        } catch (e) {
          // Expected error
        }
        
        // Should have error
        expect(
          errorContainer.read(hasOperationErrorProvider(DataOperation.itemCreate)),
          isTrue,
        );

        errorContainer.dispose();
      });
    });

    group('Concurrent Operations', () {
      test('handles multiple concurrent operations', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        
        // Start multiple operations concurrently
        final itemFuture = notifier.createItem(createTestItem());
        final containerFuture = notifier.createContainer(createTestContainer());
        final assignmentFuture = notifier.createAssignment(createTestAssignment());

        // All should be loading
        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.itemCreate),
          isTrue,
        );
        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.containerCreate),
          isTrue,
        );
        expect(
          container.read(dataOperationsNotifierProvider).isLoading(DataOperation.assignmentCreate),
          isTrue,
        );
        expect(container.read(isAnyOperationLoadingProvider), isTrue);

        // Wait for all to complete
        await Future.wait([itemFuture, containerFuture, assignmentFuture]);

        // All should be completed
        final finalState = container.read(dataOperationsNotifierProvider);
        expect(finalState.isLoading(DataOperation.itemCreate), isFalse);
        expect(finalState.isLoading(DataOperation.containerCreate), isFalse);
        expect(finalState.isLoading(DataOperation.assignmentCreate), isFalse);
        expect(finalState.hasLoadingOperations, isFalse);
      });
    });
  });
}