import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/current_item_assignments_not_null_notifier.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

class ItemEditPageArgumentExtractor extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    // Watch loading states for different operations
    final isUpdatingItem = ref.watch(isOperationLoadingProvider(DataOperation.itemUpdate));
    final isDeletingItem = ref.watch(isOperationLoadingProvider(DataOperation.itemDelete));
    final updateError = ref.watch(getOperationErrorProvider(DataOperation.itemUpdate));
    final deleteError = ref.watch(getOperationErrorProvider(DataOperation.itemDelete));
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Item page"),
            if (isUpdatingItem) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Saving...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [_deleteBtn(context, ref)],
      ),
      drawer: RescueNavigationDrawer(),
      body: Stack(
        children: [
          ItemEditPage(),
          
          // Show error banners for operations
          if (updateError != null || deleteError != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (updateError != null)
                    ErrorBanner(
                      message: 'Failed to save item: ${updateError.toString()}',
                      onRetry: () => ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemUpdate),
                      onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemUpdate),
                    ),
                  if (deleteError != null)
                    ErrorBanner(
                      message: 'Failed to delete item: ${deleteError.toString()}',
                      onRetry: () => _retryDelete(context, ref),
                      onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemDelete),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _retryDelete(BuildContext context, river.WidgetRef ref) async {
    // Clear error and retry delete operation
    ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemDelete);
    try {
      await context.performWithLoading<void>(
        operation: 'Deleting item...',
        details: 'Removing item from warehouse',
        task: () async {
          await ref.read(currentItemNotifierProvider.notifier).delete();
        },
      );
      
      if (context.mounted) {
        Navigator.popAndPushNamed(context, routeItemsOverview);
      }
    } catch (error) {
      // Error will be handled by DataOperationsNotifier and shown in banner
    }
  }

  _deleteBtn(BuildContext context, river.WidgetRef ref) {
    var currentAssignments = ref
        .watch(currentItemAssignmentsNotNullNotifierProvider)
        .keys
        .map((e) => e.printName)
        .toSet();
    var currentItem = ref.watch(currentItemNotifierProvider.notifier);
    final isDeletingItem = ref.watch(isOperationLoadingProvider(DataOperation.itemDelete));

    return DeleteButtonWithUsages(
      currentAssignments, 
      isDeletingItem ? null : () async {
        try {
          // Clear any previous errors
          ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemDelete);
          
          await context.performWithLoading<void>(
            operation: 'Deleting item...',
            details: 'Removing item from warehouse',
            task: () async {
              await currentItem.delete();
            },
          );
          
          if (context.mounted) {
            Navigator.popAndPushNamed(context, routeItemsOverview);
          }
        } catch (error) {
          // Error will be handled by DataOperationsNotifier and shown in banner
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete item: ${error.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }, 
      iconData: isDeletingItem ? Icons.hourglass_empty : Icons.delete,
    );
  }
}
