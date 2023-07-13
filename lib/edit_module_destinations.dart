import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.containerOverview),
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
      const ["Name", "Usages", ""], [..._rows(moduleDestinations), _addingRow()], {});

  List<TableRow> _rows(Map<String, Set<String>> moduleDestinations) =>
      moduleDestinations.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<String, Set<String>> destination) =>
      TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _text(destination.key)),
        RescueText.normal("Used in: ${destination.value.join(", ")}"),
        _btnDelete(destination)
      ]);

  _text(String destination) => _textField(
      TextEditingController(text: destination),
      (newText) => _changeText(destination, newText));

  _changeText(String oldDest, String newDest) =>
      Provider.of<Store>(context, listen: false)
          .editDestination(oldDest, newDest);

  _btnDelete(MapEntry<String, Set<String>> text) => TextButton(
      onPressed: () {
        Provider.of<Store>(context, listen: false).removeDestination(text.key);
      },
      child: const RescueText(24, '-', FontWeight.w700));

  TableRow _addingRow() => TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _textField(_controller)),
        Container(),
        _btnAdd()
      ]);

  _btnAdd() => TextButton(
      onPressed: () {
        Provider.of<Store>(context, listen: false)
            .addDestination(_controller.text);
        _controller.clear();
      },
      child: const RescueText(24, '+', FontWeight.w700));

  Widget _textField(TextEditingController controller,
          [ValueChanged<String>? onChange]) =>
      TextField(
        style: const TextStyle(fontSize: 24),
        decoration: const InputDecoration(
            hintText: "Insert new destination here",
            hintStyle: TextStyle(fontSize: 24)),
        controller: controller,
        onTapOutside: (_) {
          if (onChange != null) onChange(controller.text);
        },
      );
}
