import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'export_page_table.dart';
import 'rescue_text.dart';

class ExportPageBody extends StatefulWidget {
  final List<RescueContainer> containers;

  ExportPageBody(this.containers);

  @override
  State createState() => _ExportPageBodyState();
}

class _ExportPageBodyState extends State<ExportPageBody> {
  final List<ContainerPrintingOptions> options = [];
  int countAllContainers = 0;
  int countReadyContainers = 0;

  @override
  Widget build(BuildContext context) => _body();

  @override
  void initState() {
    super.initState();

    options.addAll(widget.containers
        .where((element) => element.isReady)
        .map((e) => ContainerPrintingOptions(e))
        .toList());

    countAllContainers = widget.containers.length;
    countReadyContainers = options.length;
  }

  _body() {
    return Column(
      children: [
        _topRow(),
        Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ExportPageTable(options, _adjustOption))
      ],
    );
  }

  _adjustOption(ContainerPrintingOptions option) {
    var toAdjust =
        options.firstWhere((element) => element.container == option.container);
    setState(() {
      toAdjust.printPackingList = option.printPackingList;
      toAdjust.printSafetyDatasheet = option.printSafetyDatasheet;
      toAdjust.printLabel = option.printLabel;
    });
  }

  _topRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RescueText.headline(
              "All containers marked as ready ($countReadyContainers / $countAllContainers)"),
          TextButton(
              onPressed: () {},
              child: RescueText.normal("Print selected documents"))
        ],
      );
}
