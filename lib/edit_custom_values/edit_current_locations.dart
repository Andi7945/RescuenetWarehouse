import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/edit_custom_values/proxy_current_location_usage.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_current_locations.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import '../menu.dart';
import '../rescue_table.dart';
import '../rescue_text.dart';
import 'edit_custom_value_delete_button.dart';
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
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Menu(MenuOption.containerOverview),
      Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 24),
          child: RescueText.headline("Edit current locations")),
      Expanded(child: _body())
    ]));
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
        EditCustomValueDeleteButton(withUsage.value, () {
          Provider.of<StoreCurrentLocations>(context, listen: false)
              .remove(withUsage.key);
        })
      ]);

  _textField(CurrentLocation old) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: EditCustomValueTextField(
            TextEditingController(text: old.name),
            (newValue) =>
                Provider.of<StoreCurrentLocations>(context, listen: false)
                    .edit(CurrentLocation(old.id, newValue))));
  }

  TableRow _addingRow() => TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditCustomValueTextField(_addController)),
        _btnAdd()
      ]);

  _btnAdd() => TextButton(
      onPressed: () {
        Provider.of<StoreCurrentLocations>(context, listen: false)
            .add(_addController.text);
        _addController.clear();
      },
      child: const RescueText(24, '+', FontWeight.w700));
}
