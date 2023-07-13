import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_table.dart';

import 'menu.dart';
import 'rescue_text.dart';
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
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<Store>(
            builder: (ctx, store, _) => _table(store.moduleDestinations)));
  }

  Widget _table(List<String> moduleDestinations) =>
      RescueTable(const ["Name", ""], _rows(moduleDestinations), {});

  List<TableRow> _rows(List<String> moduleDestinations) =>
      moduleDestinations.map((e) => _buildRow(e)).toList();

  TableRow _buildRow(String destination) => TableRow(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
            child: RescueText.normal(destination)),
        _deleteBtn()
      ]);

  _deleteBtn() => const RescueText(24, '-', FontWeight.w700);
}
