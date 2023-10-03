import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/export_page_body.dart';

import 'widget/rescue_navigation_drawer.dart';

class ExportPage extends StatefulWidget {
  @override
  State createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Export")),
        drawer: RescueNavigationDrawer(),
        body: _body());
  }

  _body() => Consumer<ContainerService>(
      builder: (ctxt, service, _) =>
          ExportPageBody(service.containerWithItems()));
}
