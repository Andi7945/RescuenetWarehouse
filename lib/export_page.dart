import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/export_page_table.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_table.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'menu.dart';
import 'menu_option.dart';
import 'store.dart';

class ExportPage extends StatefulWidget {
  @override
  State createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.export),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: _body()))
    ]));
  }

  _body() => Column(
        children: [
          _topRow(),
          Padding(padding: const EdgeInsets.only(top: 24.0), child: _table())
        ],
      );

  _topRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RescueText.headline("All containers marked as ready (3 / 3)"),
          TextButton(
              onPressed: () {},
              child: RescueText.normal("Print selected documents"))
        ],
      );

  _table() => Consumer<Store>(
      builder: (ctxt, store, _) => ExportPageTable(store.containers));
}
