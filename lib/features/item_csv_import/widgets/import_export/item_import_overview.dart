import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/features/item_csv_import/services/csv_to_model_importer.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/rescue_app_bar.dart';

import '../diff_viewer/split_diff_view.dart';

class ItemImportOverviewPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ItemImportOverviewPageState();
}

class _ItemImportOverviewPageState
    extends ConsumerState<ItemImportOverviewPage> {
  List<Item> _items = [];
  Map<String, Item> _existingItems = {};
  var _status = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RescueAppBar(title: "Item import overview"),
      drawer: RescueNavigationDrawer(),
      body: _body(),
    );
  }

  _body() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _importCsv,
            child: const Text('Import CSV to Items'),
          ),
          const SizedBox(height: 16),
          Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _splitView(),
        ],
      ),
    );
  }

  _splitView() {
    return Expanded(
      child: SplitDiffView<Item>(
        importedObjects: _items,
        findExistingObject: (itm) => _existingItems[itm.id],
        displayNameExtractor: (itm) => '${itm.name} (ID: ${itm.id})',
        idExtractor: (itm) => itm.id,
        alwaysShowFields: const ['id', 'name'],
        onApplyChanges: _applyChanges,
        changedSectionTitle: 'Changes to Review',
        unchangedSectionTitle: 'Unchanged Entries',
        applyButtonLabel: 'Apply All Changes',
      ),
    );
  }

  Future<void> _importCsv() async {
    try {
      // Import CSV and convert to Item objects
      final items = await CsvToModelImporter.importCsvToModel<Item>(
        fromJsonFactory: Item.fromJsonWithDateString,
      );
      var existingItems = ref
          .watch(allItemsNotifierProvider)
          .groupBy((i) => i.id)
          .mapValues((v) => v.first);
      setState(() {
        _existingItems = existingItems;
        _items = items;
        _status = 'Found ${items.length} items in the csv';
      });
    } catch (e) {
      setState(() {
        _status = 'Error importing CSV: $e';
      });
    }
  }

  void _applyChanges(List<Item> objectsToUpdateOrInsert) async {
    var repository = ref.read(itemRepositoryProvider);
    for (var item in objectsToUpdateOrInsert) {
      await repository.upsertItem(item);
    }

    // Update state
    setState(() {
      _items = [];
      _existingItems = {};
      _status =
          'Changes applied: ${objectsToUpdateOrInsert.length} updated or inserted.';
    });
  }
}
