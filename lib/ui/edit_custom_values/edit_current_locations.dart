import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/state/current_location_usage_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';

import '../rescue_table.dart';
import '../rescue_navigation_drawer.dart';
import 'edit_custom_value_text_field.dart';

class EditCurrentLocations extends river.ConsumerStatefulWidget {
  @override
  river.ConsumerState createState() => _EditCurrentLocationsState();
}

class _EditCurrentLocationsState
    extends river.ConsumerState<EditCurrentLocations> {
  final TextEditingController _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Current locations")),
        drawer: RescueNavigationDrawer(),
        body: _body());
  }

  _body() {
    var usage = ref.watch(currentLocationUsageNotifierProvider);

    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: _table(usage));
  }

  Widget _table(Map<CurrentLocation, Set<String>> withUsage) => RescueTable(
      const ["Name", ""], [..._rows(withUsage), _addingRow()], const {});

  List<TableRow> _rows(Map<CurrentLocation, Set<String>> withUsage) =>
      withUsage.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<CurrentLocation, Set<String>> withUsage) =>
      TableRow(children: [
        _textField(withUsage.key),
        DeleteButtonWithUsages(withUsage.value, () {
          ref
              .read(currentLocationsNotifierProvider.notifier)
              .delete(withUsage.key);
        })
      ]);

  _textField(CurrentLocation old) {
    return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: EditCustomValueTextField(
            TextEditingController(text: old.name),
            (newValue) => ref
                .read(currentLocationsNotifierProvider.notifier)
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
        var newLocation =
            CurrentLocation(id: uuid.v4(), name: _addController.text);
        ref.read(currentLocationsNotifierProvider.notifier).upsert(newLocation);
        _addController.clear();
      },
      icon: const Icon(Icons.add));
}
