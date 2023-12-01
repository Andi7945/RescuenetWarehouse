import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_custom_value_delete_button.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_custom_value_text_field.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/ui/rescue_table.dart';

import '../../stores.dart';
import '../rescue_navigation_drawer.dart';
import '../../proxy_module_destination_usage.dart';

class EditModuleDestinations extends StatefulWidget {
  @override
  State createState() => _EditModuleDestinationsState();
}

class _EditModuleDestinationsState extends State<EditModuleDestinations> {
  final TextEditingController _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Module destinations")),
        drawer: RescueNavigationDrawer(),
        body: _body());
  }

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<ModuleDestinationWithUsage>(
            builder: (ctx, store, _) => _table(store.destinationWithUsage)));
  }

  Widget _table(Map<ModuleDestination, Set<String>> moduleDestinations) =>
      RescueTable(const ["Name", ""],
          [..._rows(moduleDestinations), _addingRow()], const {});

  List<TableRow> _rows(
          Map<ModuleDestination, Set<String>> moduleDestinations) =>
      moduleDestinations.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<ModuleDestination, Set<String>> destination) =>
      TableRow(children: [
        _textField(destination.key),
        EditCustomValueDeleteButton(destination.value, () {
          Provider.of<StoreModuleDestination>(context, listen: false)
              .remove(destination.key);
        })
      ]);

  _textField(ModuleDestination oldDest) {
    return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: EditCustomValueTextField(
            TextEditingController(text: oldDest.name),
            (newDest) =>
                Provider.of<StoreModuleDestination>(context, listen: false)
                    .upsert(oldDest.copyWith(name: newDest))));
  }

  TableRow _addingRow() => TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 16),
            child: EditCustomValueTextField(_addController)),
        _btnAdd()
      ]);

  _btnAdd() => IconButton(
      onPressed: () {
        Provider.of<StoreModuleDestination>(context, listen: false).upsert(
            ModuleDestination(id: uuid.v4(), name: _addController.text));
        _addController.clear();
      },
      icon: const Icon(Icons.add));
}
