import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_table.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'container_overview_page_row.dart';
import 'menu.dart';
import 'rescue_container.dart';

class ContainerOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            children: [Menu(MenuOption.containerOverview), _body(context)]));
  }

  _body(context) {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<List<RescueContainer>>(
            builder: (ctxt, containers, _) => RescueTable(
                const ["", "Image", "Name", "Currently deployed", "Total amount"],
                _buildRows(context, containers),
                const {0: IntrinsicColumnWidth(), 1: IntrinsicColumnWidth()})));
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
