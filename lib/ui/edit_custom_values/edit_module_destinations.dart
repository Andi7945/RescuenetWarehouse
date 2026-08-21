import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/module_destination_usage_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_custom_value_text_field.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';

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
      Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Name
          1: FixedColumnWidth(120), // Priority
          2: FixedColumnWidth(80), // Delete
        },
        children: [
          _headerRow(),
          ..._rows(moduleDestinations),
          _addingRow(),
        ],
      );

  TableRow _headerRow() => TableRow(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );

  List<TableRow> _rows(
    Map<ModuleDestination, Set<String>> moduleDestinations,
  ) => moduleDestinations.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<ModuleDestination, Set<String>> destination) =>
      TableRow(
        children: [
          _textField(destination.key),
          _prioritySelector(destination.key),
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

  /// Load priority editor. Constructs a new [ModuleDestination] instead of
  /// using `copyWith` so that clearing the priority back to `null` works
  /// (Freezed `copyWith` cannot distinguish omitted from explicit null).
  Widget _prioritySelector(ModuleDestination destination) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: DropdownButton<int?>(
      value: destination.priority,
      isExpanded: true,
      hint: const Text('Not set'),
      items: const [
        DropdownMenuItem<int?>(value: null, child: Text('Not set')),
        DropdownMenuItem<int?>(value: 1, child: Text('1')),
        DropdownMenuItem<int?>(value: 2, child: Text('2')),
        DropdownMenuItem<int?>(value: 3, child: Text('3')),
        DropdownMenuItem<int?>(value: 4, child: Text('4')),
      ],
      onChanged: (value) => ref
          .read(moduleDestinationsNotifierProvider.notifier)
          .upsert(
            ModuleDestination(
              id: destination.id,
              name: destination.name,
              priority: value,
            ),
          ),
    ),
  );

  TableRow _addingRow() => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: EditCustomValueTextField(_addController),
      ),
      const SizedBox.shrink(), // Empty cell for priority column
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
