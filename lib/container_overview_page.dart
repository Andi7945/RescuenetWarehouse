import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'container_overview_page_headline.dart';
import 'container_overview_page_row.dart';
import 'menu.dart';
import 'rescue_container.dart';
import 'store.dart';

class ContainerOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Menu(), _body(context)]));
  }

  _body(context) {
    const BorderSide side = BorderSide(
        color: Color(0xFF000000), width: 1.0, style: BorderStyle.solid);
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<Store>(
            builder: (ctxt, store, _) => Table(
                  border: const TableBorder(
                      top: side, bottom: side, horizontalInside: side),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    ContainerOverviewPageHeadline().buildContainerHeadline(),
                    ..._buildRows(context, store.containers)
                  ],
                )));
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
