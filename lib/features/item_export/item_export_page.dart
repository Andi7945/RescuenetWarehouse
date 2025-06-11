import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/state/items_filtered_and_sorted_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_sort_button.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/items/item_grid.dart';

import 'package:rescuenet_warehouse/features/item_csv_import/services/json_to_csv_exporter.dart';
import 'item_export_buttons.dart';

class ItemExportPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemExportPageState();
}

class _ItemExportPageState extends ConsumerState<ItemExportPage> {
  List<Item> itemExportList = [];
  var itemsInList = 0;

  @override
  Widget build(BuildContext context) {
    var items = ref.watch(itemsFilteredAndSortedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item export"),
        actions: [
          ItemExportButtons(
            selectedToExport: itemsInList,
            triggerExport: () => _exportItems(itemExportList),
            triggerExportAll: () => _exportItems(items),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8, left: 8),
            child: ItemChooserAction(),
          ),
          const ItemSortButton(),
        ],
      ),
      drawer: RescueNavigationDrawer(),
      body: _body(items),
    );
  }

  _body(List<Item> items) {
    return ItemGrid(
      items: items,
      onSelect: _changeSelectionForItem,
      isSelected: itemExportList.contains,
    );
  }

  _changeSelectionForItem(Item item) {
    itemExportList.insertOrDelete(item);
    setState(() {
      itemsInList = itemExportList.length;
    });
  }

  _exportItems(List<Item> itemsToExport) {
    if (itemsToExport.isNotEmpty) {
      var items = json.encode(
        itemsToExport.map((itm) => itm.toJsonWithDateString()).toList(),
      );
      JsonToCsvExporter.convertAndExportJson(items).then((filename) {
        setState(() {
          itemExportList = [];
          itemsInList = 0;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exported CSV to $filename")));
      });
    }
  }
}
