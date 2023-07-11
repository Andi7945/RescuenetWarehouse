import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_table.dart';

import 'menu.dart';
import 'store.dart';

class EditModuleDestinations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.containerOverview),
      Expanded(child: _body())
    ]));
  }

  _body() {
    return Consumer<Store>(
        builder: (ctx, store, _) => _table(store.moduleDestinations));
  }

  Widget _table(List<String> moduleDestinations) =>
      RescueTable(const ["Name", ""], _rows(moduleDestinations), {});

  List<TableRow> _rows(List<String> moduleDestinations) => moduleDestinations
      .map((e) => TableRow(children: [Text(e), _deleteBtn()]))
      .toList();

  _deleteBtn() => const Text(
        '-',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      );
}
