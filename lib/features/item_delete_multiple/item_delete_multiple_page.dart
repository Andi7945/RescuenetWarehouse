import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/features/item_delete_multiple/item_delete_buttons.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/snackbar_utils.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/items_filtered_and_sorted_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_sort_button.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/items/item_grid.dart';

import '../../repositories/repository_providers.dart';

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
    var items = ref.watch(itemsFilteredAndSortedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete multiple items"),
        actions: [
          _action(
            ItemDeleteButtons(selected: itemsInList, triggerDeletion: _delete),
          ),
          _action(ItemChooserAction()),
          _action(ItemSortButton()),
        ],
      ),
      drawer: RescueNavigationDrawer(),
      body: _body(items),
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
    var assignments = ref
        .read(allAssignmentsNotifierProvider.notifier)
        .byItem(item.id);
    if (assignments.isEmpty) {
      itemDeletionList.insertOrDelete(item);
      setState(() {
        itemsInList = itemDeletionList.length;
      });
    } else {
      var containers = assignments.map((a) => a.containerId.toString());
      showSnackbar(
        context,
        'Can not delete item. It is still used in containers ${containers.join(", ")}',
      );
    }
  }

  _delete() {
    for (Item itm in itemDeletionList) {
      ref.read(itemRepositoryProvider).deleteItem(itm.id);
    }
    showSnackbar(context, "Deleted $itemsInList items.");
    setState(() {
      itemDeletionList = [];
      itemsInList = 0;
    });
  }
}
