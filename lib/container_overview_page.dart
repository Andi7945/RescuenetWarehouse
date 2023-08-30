import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_table.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'container_overview_page_row.dart';
import 'container_service.dart';
import 'menu.dart';
import 'rescue_container.dart';
import 'rescue_text.dart';

class ContainerOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<ContainerService>(
            builder: (ctxt, service, _) => Column(children: [
                  Menu(MenuOption.containerOverview),
                  _buttons(context, service),
                  _body(context, service)
                ])));
  }

  _buttons(BuildContext context, ContainerService service) => Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(children: [
        TextButton(
            onPressed: () async {
              var cont = await service.newContainer();
              Navigator.pushNamed(context, routeContainerEditPage,
                  arguments: cont.id);
            },
            child: RescueText.normal("Add container"))
      ]));

  _body(context, ContainerService service) {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: RescueTable(
            const ["", "Image", "Name", "Currently deployed", "Total amount"],
            _buildRows(context, service.containers()),
            const {0: IntrinsicColumnWidth(), 1: IntrinsicColumnWidth()}));
  }

  List<TableRow> _buildRows(context, List<RescueContainer> containers) =>
      containers.map((c) => _buildSingleRow(c, context)).toList();

  TableRow _buildSingleRow(container, context) =>
      ContainerOverviewPageRow().build(
          container: container,
          onClick: (RescueContainer c) => Navigator.pushNamed(
              context, routeContainerEditPage,
              arguments: c.id));
}
