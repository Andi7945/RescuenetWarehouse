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

class ItemOverviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var items = ref.watch(itemsFilteredAndSortedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item overview"),
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
      body: _body(items, context, ref),
    );
  }

  _body(List<Item> items, BuildContext context, WidgetRef ref) {
    return ItemGrid(
      items: items,
      onSelect: (itm) => _navigateToItem(itm, ref, context),
      isSelected: (_) => false,
    );
  }

  _navigateToItem(Item item, WidgetRef ref, BuildContext context) {
    ref.watch(currentItemNotifierProvider.notifier).setItem(item);
    Navigator.pushNamed(context, routeItemEditPage, arguments: item.id);
  }
}
