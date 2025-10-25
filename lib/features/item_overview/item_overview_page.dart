import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/state/items_filtered_and_sorted_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_chooser_action.dart';
import 'package:rescuenet_warehouse/features/item_overview/item_add_button.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_sort_button.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/items/item_grid.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';
import 'package:rescuenet_warehouse/widgets/rescue_app_bar.dart';

class ItemOverviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsFilteredAndSortedAsyncProvider);

    return Scaffold(
      appBar: RescueAppBar(
        title: "Item overview",
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8, left: 8),
            child: ItemChooserAction(),
          ),
          const ItemSortButton(),
          const ItemAddButton(),
        ],
      ),
      drawer: RescueNavigationDrawer(),
      body: _buildBody(context, ref, itemsAsync),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AsyncValue<List<Item>> itemsAsync) {
    return AsyncValueBuilder<List<Item>>(
      value: itemsAsync,
      data: (items) => _buildItemsContent(items, context, ref),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error, ref),
    );
  }

  Widget _buildItemsContent(List<Item> items, BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    
    return ItemGrid(
      items: items,
      onSelect: (itm) => _navigateToItem(itm, ref, context),
      isSelected: (_) => false,
    );
  }

  Widget _buildLoadingState() {
    return const DataGridLoadingIndicator(
      crossAxisCount: 2,
      itemCount: 6,
      childAspectRatio: 1.0,
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return ErrorRetryWidget.forFirebaseError(
      error: error,
      onRetry: () => ref.refresh(itemsFilteredAndSortedAsyncProvider),
      retryText: 'Reload Items',
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add new items',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToItem(Item item, WidgetRef ref, BuildContext context) {
    ref.read(currentItemNotifierProvider.notifier).setItem(item);
    Navigator.pushNamed(context, routeItemEditPage, arguments: item.id);
  }
}
