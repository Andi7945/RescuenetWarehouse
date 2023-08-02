import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:rescuenet_warehouse/pdf/packing_list_mapper.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_label.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_summary.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'pdf/data_mock_pdf.dart';
import 'export_page_table.dart';
import 'item.dart';
import 'pdf/summary_mapper.dart';
import 'pdf/pdf_creator_packing_list.dart';
import 'rescue_text.dart';

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
          TextButton(
              onPressed: () async {
                // createPdf(summaryContainer);
                var summaryPdf = await createSummaryPdf(
                    mapForPdf(widget.containerWithItems));
                Printing.sharePdf(bytes: await summaryPdf.save());
              },
              child: RescueText.normal("Print summary")),
          TextButton(
              onPressed: () async {
                // createPackingListPdf(packingList);
                var packingListPdf = await createPackingListPdf(
                    mapPackingList(widget.containerWithItems));
                Printing.sharePdf(bytes: await packingListPdf.save());
              },
              child: RescueText.normal("Print lists")),
          TextButton(
              onPressed: () async {
                var labelPdf = await createLabelPdf(
                    mapPackingList(widget.containerWithItems));
                Printing.sharePdf(bytes: await labelPdf.save());
              },
              child: RescueText.normal("Print labels"))
        ],
      );
}
