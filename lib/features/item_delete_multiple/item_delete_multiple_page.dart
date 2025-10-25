import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/features/item_delete_multiple/item_delete_buttons.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/snackbar_utils.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/items_filtered_and_sorted_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_sort_button.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/items/item_grid.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

import '../../repositories/repository_providers.dart';
import '../../widgets/rescue_app_bar.dart';

class ItemDeleteMultiplePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ItemDeleteMultiplePageState();
}

class _ItemDeleteMultiplePageState
    extends ConsumerState<ItemDeleteMultiplePage> {
  List<Item> itemDeletionList = [];
  var itemsInList = 0;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsFilteredAndSortedAsyncProvider);
    
    // Watch loading states for batch operations
    final isDeletingItems = ref.watch(isOperationLoadingProvider(DataOperation.itemBatchUpdate));

    return Scaffold(
      appBar: RescueAppBar(
        title: Row(
          children: [
            const Text("Delete multiple items"),
            if (isDeletingItems) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Deleting...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          _action(
            ItemDeleteButtons(
              selected: itemsInList,
              triggerDeletion: isDeletingItems ? null : () => _delete(context),
            ),
          ),
          _action(ItemChooserAction()),
          _action(ItemSortButton()),
        ],
      ),
      drawer: RescueNavigationDrawer(),
      body: AbsorbPointer(
        absorbing: isDeletingItems,
        child: Opacity(
          opacity: isDeletingItems ? 0.6 : 1.0,
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading items: $error',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(itemsFilteredAndSortedAsyncProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (items) => _body(items),
          ),
        ),
      ),
    );
  }

  _action(Widget btn) => Padding(padding: EdgeInsets.only(left: 4), child: btn);

  _body(List<Item> items) {
    return ItemGrid(
      items: items,
      onSelect: _changeSelectionForItem,
      isSelected: itemDeletionList.contains,
    );
  }

  _changeSelectionForItem(Item item) {
    final assignmentsAsync = ref.read(allAssignmentsAsyncProvider);
    
    assignmentsAsync.when(
      loading: () {
        // While assignments are loading, prevent selection to be safe
        showSnackbar(
          context,
          'Loading assignment data. Please wait before selecting items.',
        );
      },
      error: (error, _) {
        // On error, prevent selection to be safe
        showSnackbar(
          context,
          'Error loading assignment data. Cannot verify if item can be deleted.',
        );
      },
      data: (assignments) {
        var itemAssignments = assignments.where((a) => a.itemId == item.id).toList();
        if (itemAssignments.isEmpty) {
          itemDeletionList.insertOrDelete(item);
          setState(() {
            itemsInList = itemDeletionList.length;
          });
        } else {
          var containers = itemAssignments.map((a) => a.containerId.toString());
          showSnackbar(
            context,
            'Can not delete item. It is still used in containers ${containers.join(", ")}',
          );
        }
      },
    );
  }

  Future<void> _delete(BuildContext context) async {
    if (itemDeletionList.isEmpty) return;
    
    final itemCount = itemsInList;
    final itemNames = itemDeletionList.take(3).map((i) => i.name ?? i.id).join(', ');
    final suffix = itemDeletionList.length > 3 ? ' and ${itemDeletionList.length - 3} more' : '';
    
    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemBatchUpdate);
      
      await context.performWithLoading<void>(
        operation: 'Deleting items...',
        details: 'Removing $itemCount items: $itemNames$suffix',
        task: () async {
          // Use batch update operation for deletion (which also handles assignments)
          final repository = ref.read(itemRepositoryProvider);
          for (Item item in itemDeletionList) {
            await repository.deleteItem(item.id);
          }
        },
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted $itemCount items'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      setState(() {
        itemDeletionList = [];
        itemsInList = 0;
      });
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete items: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () => _delete(context),
              textColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        );
      }
    }
  }
}
