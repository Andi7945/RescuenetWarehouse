import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/module_destination_usage_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_custom_value_text_field.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/ui/rescue_table.dart';

import '../rescue_navigation_drawer.dart';
import '../../widgets/rescue_app_bar.dart';

class EditModuleDestinations extends river.ConsumerStatefulWidget {
  @override
  river.ConsumerState createState() => _EditModuleDestinationsState();
}

class _EditModuleDestinationsState
    extends river.ConsumerState<EditModuleDestinations> {
  final TextEditingController _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RescueAppBar(title: "Module destinations"),
      drawer: RescueNavigationDrawer(),
      body: _body(),
    );
  }

  _body() {
    var usageAsync = ref.watch(moduleDestinationUsageNotifierProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: usageAsync.when(
        data: (usage) => _table(usage),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading module destinations: $error'),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(moduleDestinationUsageNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table(Map<ModuleDestination, Set<String>> moduleDestinations) =>
      RescueTable(
        const ["Name", ""],
        [..._rows(moduleDestinations), _addingRow()],
        const {},
      );

  List<TableRow> _rows(
    Map<ModuleDestination, Set<String>> moduleDestinations,
  ) => moduleDestinations.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<ModuleDestination, Set<String>> destination) =>
      TableRow(
        children: [
          _textField(destination.key),
          DeleteButtonWithUsages(destination.value, () {
            ref
                .read(moduleDestinationsNotifierProvider.notifier)
                .delete(destination.key);
          }),
        ],
      );

  _textField(ModuleDestination oldDest) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: EditCustomValueTextField(
        TextEditingController(text: oldDest.name),
        (newDest) => ref
            .read(moduleDestinationsNotifierProvider.notifier)
            .upsert(oldDest.copyWith(name: newDest)),
      ),
    );
  }

  TableRow _addingRow() => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: EditCustomValueTextField(_addController),
      ),
      _btnAdd(),
    ],
  );

  _btnAdd() => IconButton(
    onPressed: () {
      var newDestination = ModuleDestination(
        id: uuid.v4(),
        name: _addController.text,
      );
      ref
          .read(moduleDestinationsNotifierProvider.notifier)
          .upsert(newDestination);
      _addController.clear();
    },
    icon: const Icon(Icons.add),
  );
}
