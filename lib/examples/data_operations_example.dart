/// Example demonstrating how to use DataOperationsNotifier with loading widgets.
library;

/// This file shows comprehensive examples of integrating the DataOperationsNotifier
/// with the loading widgets to provide user feedback during CRUD operations.
///
/// DO NOT USE IN PRODUCTION - This is for documentation and testing purposes only.
///
/// Author: Claude Code Assistant
/// Date: 2025-08-10

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../models/assignment.dart';
import '../state/data_operations_notifier.dart';
import '../widgets/loading/operation_loading_overlay.dart';

/// Example widget showing how to use DataOperationsNotifier for Item operations
class ItemOperationsExample extends ConsumerWidget {
  const ItemOperationsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the overall operations state
    final operationsState = ref.watch(dataOperationsNotifierProvider);

    // Watch specific operation loading states using convenience providers
    final isCreatingItem = ref.watch(
      isOperationLoadingProvider(DataOperation.itemCreate),
    );
    final isUpdatingItem = ref.watch(
      isOperationLoadingProvider(DataOperation.itemUpdate),
    );
    final isDeletingItem = ref.watch(
      isOperationLoadingProvider(DataOperation.itemDelete),
    );

    // Get operation errors if any
    final createError = ref.watch(
      getOperationErrorProvider(DataOperation.itemCreate),
    );
    final updateError = ref.watch(
      getOperationErrorProvider(DataOperation.itemUpdate),
    );
    final deleteError = ref.watch(
      getOperationErrorProvider(DataOperation.itemDelete),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Operations Example'),
        // Show loading indicator in app bar if any operation is active
        actions: [
          if (operationsState.hasLoadingOperations)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create Item Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (createError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Error: $createError',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: isCreatingItem
                          ? null
                          : () => _createItemExample(context, ref),
                      child: isCreatingItem
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Creating...'),
                              ],
                            )
                          : const Text('Create Example Item'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Update Item Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (updateError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Error: $updateError',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: isUpdatingItem
                          ? null
                          : () => _updateItemExample(context, ref),
                      child: isUpdatingItem
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Updating...'),
                              ],
                            )
                          : const Text('Update Example Item'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delete Item Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete Item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (deleteError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Error: $deleteError',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: isDeletingItem
                          ? null
                          : () => _deleteItemExample(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      child: isDeletingItem
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Deleting...'),
                              ],
                            )
                          : const Text('Delete Example Item'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Batch Operations Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch Operations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          operationsState.isLoading(
                            DataOperation.itemBatchUpdate,
                          )
                          ? null
                          : () => _batchUpdateItemsExample(context, ref),
                      child:
                          operationsState.isLoading(
                            DataOperation.itemBatchUpdate,
                          )
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Batch Updating...'),
                              ],
                            )
                          : const Text('Batch Update Items'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example of creating an item with loading state management
  Future<void> _createItemExample(BuildContext context, WidgetRef ref) async {
    // Clear any previous errors
    ref
        .read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemCreate);

    // Create example item
    final newItem = Item(
      id: 'example-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Example Item',
      rescueNetId: 12345.0,
      totalAmount: 10,
      description: 'Created via DataOperationsNotifier example',
    );

    try {
      // The notifier will handle loading states automatically
      await ref
          .read(dataOperationsNotifierProvider.notifier)
          .createItem(newItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Example of updating an item with loading state management
  Future<void> _updateItemExample(BuildContext context, WidgetRef ref) async {
    // Clear any previous errors
    ref
        .read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemUpdate);

    // Update example item
    final updatedItem = Item(
      id: 'example-update',
      name: 'Updated Example Item',
      rescueNetId: 54321.0,
      totalAmount: 20,
      description: 'Updated via DataOperationsNotifier example',
    );

    try {
      await ref
          .read(dataOperationsNotifierProvider.notifier)
          .updateItem(updatedItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Example of deleting an item with loading state management
  Future<void> _deleteItemExample(BuildContext context, WidgetRef ref) async {
    // Clear any previous errors
    ref
        .read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemDelete);

    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(dataOperationsNotifierProvider.notifier)
          .deleteItem('example-delete-id');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Example of batch updating items with loading state management
  Future<void> _batchUpdateItemsExample(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Clear any previous errors
    ref
        .read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemBatchUpdate);

    // Create batch of items
    final items = List.generate(
      5,
      (index) => Item(
        id: 'batch-item-$index',
        name: 'Batch Item $index',
        rescueNetId: (10000 + index).toDouble(),
        totalAmount: (index + 1) * 5,
        description: 'Batch created item $index',
      ),
    );

    try {
      await ref
          .read(dataOperationsNotifierProvider.notifier)
          .batchUpdateItems(items);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${items.length} items updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to batch update items: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Example of using DataOperationsNotifier with OperationLoadingOverlay
class OverlayOperationsExample extends ConsumerWidget {
  const OverlayOperationsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overlay Operations Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _createItemWithOverlay(context, ref),
              child: const Text('Create Item with Overlay'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _batchOperationWithOverlay(context, ref),
              child: const Text('Batch Operation with Overlay'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _assignmentOperationWithOverlay(context, ref),
              child: const Text('Assignment Operation with Overlay'),
            ),
          ],
        ),
      ),
    );
  }

  /// Example using the performWithLoading extension method
  Future<void> _createItemWithOverlay(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await context.performWithLoading<void>(
        operation: 'Creating new item...',
        details: 'Please wait while we save your item',
        task: () async {
          final newItem = Item(
            id: 'overlay-example-${DateTime.now().millisecondsSinceEpoch}',
            name: 'Overlay Example Item',
            rescueNetId: 99999.0,
            totalAmount: 15,
            description: 'Created with loading overlay',
          );

          await ref
              .read(dataOperationsNotifierProvider.notifier)
              .createItem(newItem);

          // Simulate some additional processing time
          await Future.delayed(const Duration(seconds: 1));
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created with overlay!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Example of batch operation with overlay
  Future<void> _batchOperationWithOverlay(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await context.performWithLoading<void>(
        operation: 'Processing batch operation...',
        details: 'Updating multiple items at once',
        task: () async {
          final items = List.generate(
            3,
            (index) => Item(
              id: 'batch-overlay-$index',
              name: 'Batch Overlay Item $index',
              rescueNetId: (20000 + index).toDouble(),
              totalAmount: (index + 1) * 3,
              description: 'Batch processed with overlay',
            ),
          );

          await ref
              .read(dataOperationsNotifierProvider.notifier)
              .batchUpdateItems(items);
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch operation completed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batch operation failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Example of assignment operation with overlay
  Future<void> _assignmentOperationWithOverlay(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await context.performWithLoading<void>(
        operation: 'Creating assignment...',
        details: 'Linking item to container',
        task: () async {
          final assignment = Assignment(
            id: 'overlay-assignment-${DateTime.now().millisecondsSinceEpoch}',
            itemId: 'example-item-id',
            containerId: 'example-container-id',
            count: 5,
          );

          await ref
              .read(dataOperationsNotifierProvider.notifier)
              .createAssignment(assignment);
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assignment failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Example showing how to watch multiple operations simultaneously
class MultiOperationExample extends ConsumerWidget {
  const MultiOperationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch multiple operations
    final isAnyLoading = ref.watch(isAnyOperationLoadingProvider);
    final itemCreateLoading = ref.watch(
      isOperationLoadingProvider(DataOperation.itemCreate),
    );
    final containerCreateLoading = ref.watch(
      isOperationLoadingProvider(DataOperation.containerCreate),
    );
    final assignmentCreateLoading = ref.watch(
      isOperationLoadingProvider(DataOperation.assignmentCreate),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Operation Example'),
        // Show overall loading state
        backgroundColor: isAnyLoading
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operation Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow('Item Creation', itemCreateLoading),
                    _buildStatusRow(
                      'Container Creation',
                      containerCreateLoading,
                    ),
                    _buildStatusRow(
                      'Assignment Creation',
                      assignmentCreateLoading,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Any Loading: ${isAnyLoading ? "Yes" : "No"}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAnyLoading
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            ElevatedButton(
              onPressed: itemCreateLoading
                  ? null
                  : () => _triggerItemOperation(ref),
              child: const Text('Trigger Item Operation'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: containerCreateLoading
                  ? null
                  : () => _triggerContainerOperation(ref),
              child: const Text('Trigger Container Operation'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: assignmentCreateLoading
                  ? null
                  : () => _triggerAssignmentOperation(ref),
              child: const Text('Trigger Assignment Operation'),
            ),

            const Spacer(),

            // Clear all operations button
            if (isAnyLoading)
              ElevatedButton(
                onPressed: () => ref
                    .read(dataOperationsNotifierProvider.notifier)
                    .clearAll(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Clear All Operations'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String operation, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: isLoading
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Icon(Icons.check_circle, size: 16, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Text(operation),
        ],
      ),
    );
  }

  Future<void> _triggerItemOperation(WidgetRef ref) async {
    try {
      final item = Item(
        id: 'multi-item-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Multi Example Item',
        rescueNetId: 30000.0,
        totalAmount: 1,
      );

      await ref.read(dataOperationsNotifierProvider.notifier).createItem(item);

      // Simulate some work
      await Future.delayed(const Duration(seconds: 2));
    } catch (error) {
      // Error will be tracked in the operations state
    }
  }

  Future<void> _triggerContainerOperation(WidgetRef ref) async {
    try {
      // Note: This would need a real ContainerDao object in practice
      // await ref.read(dataOperationsNotifierProvider.notifier).createContainer(container);

      // Simulate container creation for demo
      await Future.delayed(const Duration(seconds: 3));
    } catch (error) {
      // Error will be tracked in the operations state
    }
  }

  Future<void> _triggerAssignmentOperation(WidgetRef ref) async {
    try {
      final assignment = Assignment(
        id: 'multi-assignment-${DateTime.now().millisecondsSinceEpoch}',
        itemId: 'example-item',
        containerId: 'example-container',
        count: 2,
      );

      await ref
          .read(dataOperationsNotifierProvider.notifier)
          .createAssignment(assignment);

      // Simulate some work
      await Future.delayed(const Duration(seconds: 1));
    } catch (error) {
      // Error will be tracked in the operations state
    }
  }
}
