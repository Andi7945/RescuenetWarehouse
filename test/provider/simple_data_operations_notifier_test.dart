import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/repositories/item_repository.dart';
import 'package:rescuenet_warehouse/repositories/container_repository.dart';
import 'package:rescuenet_warehouse/repositories/assignment_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_item_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_assignment_repository.dart';

/// Simplified test file for DataOperationsNotifier
/// 
/// This file tests the DataOperationsNotifier without the complex provider setup
/// that requires dart:html imports.
void main() {
  group('DataOperationsNotifier Simple Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Create container with simple mock repositories
      container = ProviderContainer(
        overrides: [
          itemRepositoryProvider.overrideWithValue(MockItemRepository()),
          containerRepositoryProvider.overrideWithValue(MockContainerRepository()),
          assignmentRepositoryProvider.overrideWithValue(MockAssignmentRepository()),
        ],
      );
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
      });
    });

    group('Item Operations', () {
      test('createItem sets loading state during operation', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItem = Item(
          id: 'test-item',
          name: 'Test Item',
          rescueNetId: 1001.0,
          totalAmount: 10,
          weight: 1.5,
          description: 'Test description',
          operationalStatus: OperationalStatus.deployable,
        );

        // Start the operation
        final future = notifier.createItem(testItem);

        // Check that loading state is set
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

      test('updateItem sets loading state during operation', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItem = Item(
          id: 'test-item-2',
          name: 'Test Item 2',
          rescueNetId: 1002.0,
          totalAmount: 5,
          weight: 2.0,
          operationalStatus: OperationalStatus.deployable,
        );

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

      test('deleteItem sets loading state during operation', () async {
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

      test('handles errors correctly', () async {
        // Override with error-throwing repository
        final errorContainer = ProviderContainer(
          overrides: [
            itemRepositoryProvider.overrideWithValue(_ThrowingMockItemRepository()),
          ],
        );

        final notifier = errorContainer.read(dataOperationsNotifierProvider.notifier);
        final testItem = Item(
          id: 'test-error-item',
          name: 'Error Item',
          rescueNetId: 9999.0,
          totalAmount: 1,
          operationalStatus: OperationalStatus.deployable,
        );

        try {
          await notifier.createItem(testItem);
          fail('Expected exception was not thrown');
        } catch (e) {
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
      test('createContainer sets loading state during operation', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testContainer = ContainerDao(
          id: 'test-container',
          number: 1,
          name: 'Test Container',
          sequentialBuild: 1,
          isReady: true,
          toDeploy: false,
        );

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

      test('updateContainer sets loading state during operation', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testContainer = ContainerDao(
          id: 'test-container-2',
          number: 2,
          name: 'Test Container 2',
          sequentialBuild: 1,
          isReady: false,
          toDeploy: true,
        );

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
    });

    group('Assignment Operations', () {
      test('createAssignment sets loading state during operation', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testAssignment = Assignment(
          id: 'test-assignment',
          itemId: 'test-item',
          containerId: 'test-container',
          count: 5,
        );

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

      test('upsertOrDeleteAssignment sets loading state during operation', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testAssignment = Assignment(
          id: 'test-assignment-2',
          itemId: 'test-item-2',
          containerId: 'test-container-2',
          count: 3,
        );

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
    });

    group('Convenience Providers', () {
      test('isAnyOperationLoading tracks global loading state', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItem = Item(
          id: 'test-loading-item',
          name: 'Loading Test Item',
          rescueNetId: 2001.0,
          totalAmount: 15,
          operationalStatus: OperationalStatus.deployable,
        );
        
        // Initially no operations loading
        expect(container.read(isAnyOperationLoadingProvider), isFalse);

        // Start an operation
        final future = notifier.createItem(testItem);
        
        // Should be loading
        expect(container.read(isAnyOperationLoadingProvider), isTrue);

        // Complete operation
        await future;
        
        // Should no longer be loading
        expect(container.read(isAnyOperationLoadingProvider), isFalse);
      });

      test('isOperationLoading tracks specific operation state', () async {
        final notifier = container.read(dataOperationsNotifierProvider.notifier);
        final testItem = Item(
          id: 'test-specific-item',
          name: 'Specific Test Item',
          rescueNetId: 2002.0,
          totalAmount: 20,
          operationalStatus: OperationalStatus.deployable,
        );
        
        // Initially not loading
        expect(
          container.read(isOperationLoadingProvider(DataOperation.itemCreate)),
          isFalse,
        );

        // Start item creation
        final itemFuture = notifier.createItem(testItem);
        
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
  });
}

// Simple error throwing mock for testing
class _ThrowingMockItemRepository implements ItemRepository {
  @override
  Future<void> upsertItem(Item item) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock repository error');
  }

  @override
  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock delete error');
  }

  @override
  Future<void> batchUpdateItems(List<Item> items) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock batch update error');
  }

  @override
  Stream<List<Item>> watchItems() => throw Exception('Mock watch error');

  @override
  Future<Item?> getItem(String id) async => throw Exception('Mock get error');

  @override
  Future<List<Item>> searchItems(String query) async => throw Exception('Mock search error');

  @override
  Future<List<Item>> getItemsByStatus(String operationalStatus) async => 
      throw Exception('Mock get by status error');
}