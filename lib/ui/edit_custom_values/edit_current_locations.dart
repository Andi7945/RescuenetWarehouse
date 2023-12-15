import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/proxy_current_location_usage.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';

import '../rescue_table.dart';
import '../../stores.dart';
import '../rescue_navigation_drawer.dart';
import 'edit_custom_value_text_field.dart';

class EditCurrentLocations extends StatefulWidget {
  @override
  State createState() => _EditCurrentLocationsState();
}

class _EditCurrentLocationsState extends State<EditCurrentLocations> {
  final TextEditingController _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Current locations")),
        drawer: RescueNavigationDrawer(),
        body: _body());
  }

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<CurrentLocationsWithUsage>(
            builder: (ctx, store, _) =>
                _table(store.currentLocationsWithUsage)));
  }

  Widget _table(Map<CurrentLocation, Set<String>> withUsage) => RescueTable(
      const ["Name", ""], [..._rows(withUsage), _addingRow()], const {});

  List<TableRow> _rows(Map<CurrentLocation, Set<String>> withUsage) =>
      withUsage.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<CurrentLocation, Set<String>> withUsage) =>
      TableRow(children: [
        _textField(withUsage.key),
        DeleteButtonWithUsages(withUsage.value, () {
          Provider.of<StoreCurrentLocations>(context, listen: false)
              .remove(withUsage.key);
        })
      ]);

  _textField(CurrentLocation old) {
    return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: EditCustomValueTextField(
            TextEditingController(text: old.name),
            (newValue) =>
                Provider.of<StoreCurrentLocations>(context, listen: false)
                    .upsert(old.copyWith(name: newValue))));
  }

  TableRow _addingRow() => TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 16),
            child: EditCustomValueTextField(_addController)),
        _btnAdd()
      ]);

  _btnAdd() => IconButton(
      onPressed: () {
        Provider.of<StoreCurrentLocations>(context, listen: false)
            .upsert(CurrentLocation(id: uuid.v4(), name: _addController.text));
        _addController.clear();
      },
      icon: const Icon(Icons.add));
}
