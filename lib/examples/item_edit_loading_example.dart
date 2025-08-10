/// Example demonstrating the complete item loading states integration.
library;

/// This file shows how the item edit page now integrates with DataOperationsNotifier
/// to provide comprehensive loading states and error handling for item operations.
///
/// Key features demonstrated:
/// - Loading states during item creation, update, and deletion
/// - Error handling with user-friendly messages and retry functionality
/// - Loading overlays for operations
/// - Form field disabling during operations
/// - Visual feedback in buttons and input fields
///
/// DO NOT USE IN PRODUCTION - This is for documentation and testing purposes only.
///
/// Author: Claude Code Assistant
/// Date: 2025-08-10

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/current_item_notifier.dart';
import '../state/data_operations_notifier.dart';
import '../widgets/loading/loading_widgets.dart';

/// Example widget that demonstrates the integrated item loading states
class ItemEditLoadingExample extends ConsumerStatefulWidget {
  const ItemEditLoadingExample({super.key});

  @override
  ConsumerState<ItemEditLoadingExample> createState() => _ItemEditLoadingExampleState();
}

class _ItemEditLoadingExampleState extends ConsumerState<ItemEditLoadingExample> {
  final TextEditingController _nameController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current item and operation states
    final currentItem = ref.watch(currentItemNotifierProvider);
    final isCreating = ref.watch(isOperationLoadingProvider(DataOperation.itemCreate));
    final isUpdating = ref.watch(isOperationLoadingProvider(DataOperation.itemUpdate));
    final isDeleting = ref.watch(isOperationLoadingProvider(DataOperation.itemDelete));
    
    final createError = ref.watch(getOperationErrorProvider(DataOperation.itemCreate));
    final updateError = ref.watch(getOperationErrorProvider(DataOperation.itemUpdate));
    final deleteError = ref.watch(getOperationErrorProvider(DataOperation.itemDelete));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Item Loading States Example'),
            if (isUpdating) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              const Text('Saving...', style: TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banners
            if (createError != null)
              ErrorBanner(
                message: 'Failed to create item: ${createError.toString()}',
                onRetry: () => _retryCreateItem(),
                onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier)
                    .clearOperation(DataOperation.itemCreate),
              ),
            
            if (updateError != null)
              ErrorBanner(
                message: 'Failed to update item: ${updateError.toString()}',
                onRetry: () => _retryUpdateItem(),
                onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier)
                    .clearOperation(DataOperation.itemUpdate),
              ),
            
            if (deleteError != null)
              ErrorBanner(
                message: 'Failed to delete item: ${deleteError.toString()}',
                onRetry: () => _retryDeleteItem(),
                onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier)
                    .clearOperation(DataOperation.itemDelete),
              ),

            const SizedBox(height: 16),

            // Item creation section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Creation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isCreating ? null : _createNewItem,
                      child: isCreating
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Creating...'),
                              ],
                            )
                          : const Text('Create New Item'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Item editing section
            if (currentItem != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Editing',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text('ID: ${currentItem.id}'),
                      Text('RescueNet ID: ${currentItem.rescueNetId.toInt()}'),
                      const SizedBox(height: 12),
                      
                      // Name editing with loading state
                      Stack(
                        children: [
                          TextField(
                            controller: _nameController..text = currentItem.name ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Item Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: isUpdating ? null : _updateItemName,
                          ),
                          if (isUpdating)
                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                            ),
                          if (isUpdating)
                            Positioned.fill(
                              child: Container(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Delete button
                      ElevatedButton(
                        onPressed: isDeleting ? null : _deleteItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                        child: isDeleting
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Deleting...'),
                                ],
                              )
                            : const Text('Delete Item'),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Status information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operation Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Creating: ${isCreating ? "Yes" : "No"}'),
                    Text('Updating: ${isUpdating ? "Yes" : "No"}'),
                    Text('Deleting: ${isDeleting ? "Yes" : "No"}'),
                    Text('Current Item: ${currentItem?.name ?? "None"}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewItem() async {
    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier)
          .clearOperation(DataOperation.itemCreate);
      
      // Use loading overlay for item creation
      await context.performWithLoading<void>(
        operation: 'Creating new item...',
        details: 'Setting up item for editing',
        task: () async {
          await ref.read(currentItemNotifierProvider.notifier).addItem();
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create item: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _updateItemName(String newName) async {
    final currentItem = ref.read(currentItemNotifierProvider);
    if (currentItem != null && currentItem.name != newName) {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier)
          .clearOperation(DataOperation.itemUpdate);
      
      try {
        await ref.read(currentItemNotifierProvider.notifier)
            .update(currentItem.copyWith(name: newName));
      } catch (error) {
        // Error will be handled by DataOperationsNotifier and shown in banner
      }
    }
  }

  Future<void> _deleteItem() async {
    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier)
          .clearOperation(DataOperation.itemDelete);
      
      // Use loading overlay for item deletion
      await context.performWithLoading<void>(
        operation: 'Deleting item...',
        details: 'Removing item from warehouse',
        task: () async {
          await ref.read(currentItemNotifierProvider.notifier).delete();
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete item: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _retryCreateItem() {
    ref.read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemCreate);
    _createNewItem();
  }

  void _retryUpdateItem() {
    final currentItem = ref.read(currentItemNotifierProvider);
    if (currentItem != null) {
      ref.read(dataOperationsNotifierProvider.notifier)
          .clearOperation(DataOperation.itemUpdate);
      _updateItemName(_nameController.text);
    }
  }

  void _retryDeleteItem() {
    ref.read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemDelete);
    _deleteItem();
  }
}