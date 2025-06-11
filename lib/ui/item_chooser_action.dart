import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/items_filtered_and_sorted_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_filter_modal.dart';

class ItemChooserAction extends ConsumerWidget {
  const ItemChooserAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var allItems = ref.watch(allItemsNotifierProvider).length;
    var filteredItems =
        ref.watch(itemsFilteredAndSortedNotifierProvider).length;

    return ActionChip(
        label: Row(children: [
          Text("$filteredItems / $allItems"),
          const Icon(Icons.filter_alt, color: Colors.blue)
        ]),
        onPressed: () {
          showDialog(context: context, builder: (ctx) => ItemFilterModal());
        });
  }
}
