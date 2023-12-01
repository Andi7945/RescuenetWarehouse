import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/export_service.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import 'export_page_table.dart';

class ExportPageBody extends StatefulWidget {
  final Map<RescueContainer, Map<Item, int>> containerWithItems;

  ExportPageBody(this.containerWithItems);

  @override
  State createState() => _ExportPageBodyState();
}

class _ExportPageBodyState extends State<ExportPageBody> {
  final List<ContainerPrintingOptions> options = [];

  @override
  Widget build(BuildContext context) => _body();

  @override
  void initState() {
    super.initState();

    options.addAll(widget.containerWithItems.keys
        .where((element) => element.isReady)
        .map((e) => ContainerPrintingOptions(e))
        .toList());

    options.sort((a, b) => a.container.number.compareTo(b.container.number));
  }

  _body() => Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: ExportPageTable(options, _adjustOption, _sharePackingListPdf,
          _shareLabelPdf, _shareSafetyDatasheets));

  _adjustOption(ContainerPrintingOptions option) {
    var toAdjust =
        options.firstWhere((element) => element.container == option.container);
    setState(() {
      toAdjust.printPackingList = option.printPackingList;
      toAdjust.printSafetyDatasheet = option.printSafetyDatasheet;
      toAdjust.printLabel = option.printLabel;
    });
  }

  _sharePackingListPdf() {
    var toPrint = options
        .where((ele) => ele.printPackingList)
        .map((e) => e.container)
        .toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    sharePackingListPdf(withItems, context);
  }

  _shareLabelPdf() {
    var toPrint =
        options.where((ele) => ele.printLabel).map((e) => e.container).toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    shareLabelPdf(withItems, context);
  }

  _shareSafetyDatasheets() {
    var toPrint = options
        .where((ele) => ele.printSafetyDatasheet)
        .map((e) => e.container)
        .toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    shareSafetyDatasheets(withItems, context);
  }
}
