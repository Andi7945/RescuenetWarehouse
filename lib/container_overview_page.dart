import 'package:flutter/material.dart';

import 'container_overview_page_headline.dart';
import 'container_overview_page_row.dart';
import 'menu.dart';
import 'rescue_container.dart';

class ContainerOverviewPage extends StatelessWidget {
  final List<RescueContainer> _containers;

  ContainerOverviewPage(this._containers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Menu(), _bodyTable()]));
  }

  _bodyTable() {
    const BorderSide side = BorderSide(
        color: Color(0xFF000000), width: 1.0, style: BorderStyle.solid);
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Table(
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
            ..._containers.map((e) => ContainerOverviewPageRow().build(e))
          ],
        ));
  }
}
