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
    final filteredItemsAsync = ref.watch(itemsFilteredAndSortedAsyncProvider);

    return filteredItemsAsync.when(
      loading: () => ActionChip(
        label: Row(children: [
          Text("... / $allItems"),
          const SizedBox(width: 8),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.filter_alt, color: Colors.blue)
        ]),
        onPressed: () {
          showDialog(context: context, builder: (ctx) => ItemFilterModal());
        },
      ),
      error: (error, stackTrace) => ActionChip(
        label: Row(children: [
          Text("Error / $allItems"),
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          const Icon(Icons.filter_alt, color: Colors.blue)
        ]),
        onPressed: () {
          showDialog(context: context, builder: (ctx) => ItemFilterModal());
        },
      ),
      data: (filteredItems) => ActionChip(
        label: Row(children: [
          Text("${filteredItems.length} / $allItems"),
          const Icon(Icons.filter_alt, color: Colors.blue)
        ]),
        onPressed: () {
          showDialog(context: context, builder: (ctx) => ItemFilterModal());
        },
      ),
    );
  }
}
