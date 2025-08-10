import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

class ItemAddButton extends ConsumerWidget {
  const ItemAddButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch loading state for item creation
    final isCreatingItem = ref.watch(isOperationLoadingProvider(DataOperation.itemCreate));
    final createError = ref.watch(getOperationErrorProvider(DataOperation.itemCreate));
    
    return IconButton(
      onPressed: isCreatingItem ? null : () => _createNewItem(context, ref),
      icon: isCreatingItem 
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.add),
      tooltip: isCreatingItem 
        ? 'Creating item...' 
        : createError != null 
          ? 'Error creating item: ${createError.toString()}'
          : 'Add new item',
    );
  }
  
  Future<void> _createNewItem(BuildContext context, WidgetRef ref) async {
    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemCreate);
      
      // Use loading overlay for item creation
      await context.performWithLoading<void>(
        operation: 'Creating new item...',
        details: 'Setting up item for editing',
        task: () async {
          await ref.read(currentItemNotifierProvider.notifier).addItem();
        },
      );

      if (context.mounted) {
        Navigator.pushNamed(context, routeItemEditPage);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create item: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () => _createNewItem(context, ref),
              textColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        );
      }
    }
  }
}
