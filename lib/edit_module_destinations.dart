import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/edit_custom_value_delete_button.dart';
import 'package:rescuenet_warehouse/edit_custom_value_text_field.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_table.dart';

import 'menu.dart';
import 'rescue_text.dart';
import 'store.dart';

class EditModuleDestinations extends StatefulWidget {
  @override
  State createState() => _EditModuleDestinationsState();
}

class _EditModuleDestinationsState extends State<EditModuleDestinations> {
  final TextEditingController _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Menu(MenuOption.containerOverview),
      Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 24),
          child: RescueText.headline("Edit module destinations")),
      Expanded(child: _body())
    ]));
  }

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<Store>(
            builder: (ctx, store, _) =>
                _table(store.moduleDestinationsWithUsage)));
  }

  Widget _table(Map<String, Set<String>> moduleDestinations) => RescueTable(
      const ["Name", ""],
      [..._rows(moduleDestinations), _addingRow()],
      const {});

  List<TableRow> _rows(Map<String, Set<String>> moduleDestinations) =>
      moduleDestinations.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<String, Set<String>> destination) =>
      TableRow(children: [
        _textField(destination.key),
        EditCustomValueDeleteButton(destination.key, destination.value)
      ]);

  _textField(String oldDest) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: EditCustomValueTextField(
            TextEditingController(text: oldDest),
            (newDest) => Provider.of<Store>(context, listen: false)
                .editDestination(oldDest, newDest)));
  }

  TableRow _addingRow() => TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditCustomValueTextField(_addController)),
        _btnAdd()
      ]);

  _btnAdd() => TextButton(
      onPressed: () {
        Provider.of<Store>(context, listen: false)
            .addDestination(_addController.text);
        _addController.clear();
      },
      child: const RescueText(24, '+', FontWeight.w700));
}
