import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:rescuenet_warehouse/pdf/packing_list_mapper.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_label.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_summary.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'export_page_table.dart';
import 'item.dart';
import 'pdf/summary_mapper.dart';
import 'pdf/pdf_creator_packing_list.dart';
import 'rescue_text.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportPageBody extends StatefulWidget {
  final Map<RescueContainer, Map<Item, int>> containerWithItems;

  ExportPageBody(this.containerWithItems);

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

    options.addAll(widget.containerWithItems.keys
        .where((element) => element.isReady)
        .map((e) => ContainerPrintingOptions(e))
        .toList());

    countAllContainers = widget.containerWithItems.length;
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
          _btn("Print summary", _shareSummaryPdf),
          _btn("Print lists", _sharePackingListPdf),
          _btn("Print labels", _shareLabelPdf)
        ],
      );

  Future<pw.Document> _shareSummaryPdf() {
    var forContainers = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => ele.key.isReady && ele.key.toDeploy));
    return createSummaryPdf(mapForPdf(forContainers));
  }

  Future<pw.Document> _sharePackingListPdf() {
    var toPrint = options
        .where((ele) => ele.printPackingList)
        .map((e) => e.container)
        .toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    return createPackingListPdf(mapPackingList(withItems));
  }

  Future<pw.Document> _shareLabelPdf() {
    var toPrint =
        options.where((ele) => ele.printLabel).map((e) => e.container).toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    return createLabelPdf(mapPackingList(withItems));
  }

  Widget _btn(String label, Future<pw.Document> Function() pdf) => TextButton(
      onPressed: () async {
        var labelPdf = await pdf();
        Printing.sharePdf(bytes: await labelPdf.save());
      },
      child: RescueText.normal(label));
}
