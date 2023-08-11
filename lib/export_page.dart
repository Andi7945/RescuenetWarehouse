import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/export_page_body.dart';

import 'menu.dart';
import 'menu_option.dart';

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

  _body() => Consumer<ContainerService>(
      builder: (ctxt, service, _) =>
          ExportPageBody(service.containerWithItems()));
}
