import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';

import '../../export_service.dart';
import '../../models/item.dart';
import '../../models/rescue_container.dart';
import '../rescue_text.dart';
import '../rescue_navigation_drawer.dart';
import 'export_page_body.dart';

class ExportPage extends StatefulWidget {
  @override
  State createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerService>(builder: (ctxt, service, _) {
      var allContainersWithItems = service.containerWithItems();

      return Scaffold(
          appBar: AppBar(
              title: const Text("Ready containers"),
              actions: [_summaryButton(allContainersWithItems)]),
          drawer: RescueNavigationDrawer(),
          body: ExportPageBody(service.containerWithItems()));
    });
  }

  Widget _summaryButton(
          Map<RescueContainer, Map<Item, int>> allContainersWithItems) =>
      ActionChip(
          onPressed: () async {
            await _shareSummaryPdf(allContainersWithItems);
          },
          label: RescueText.slim("Print final summary"));

  _shareSummaryPdf(Map<RescueContainer, Map<Item, int>> withItems) {
    var forContainers = Map.fromEntries(
        withItems.entries.where((ele) => ele.key.isReady && ele.key.toDeploy));
    shareSummaryPdf(forContainers, context);
  }
}
