import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
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
import 'package:firebase_storage/firebase_storage.dart';

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
            child: ExportPageTable(options, _adjustOption, _sharePackingListPdf,
                _shareLabelPdf, _shareSafetyDatasheets))
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
          _summaryButton()
        ],
      );

  Widget _summaryButton() => TextButton(
      onPressed: () async {
        var file = await _shareSummaryPdf();
        Printing.sharePdf(bytes: await file.save());
      },
      child: RescueText.normal("Print final summary"));

  Future<pw.Document> _shareSummaryPdf() {
    var forContainers = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => ele.key.isReady && ele.key.toDeploy));
    return createSummaryPdf(mapForPdf(forContainers));
  }

  void _sharePackingListPdf() async {
    var toPrint = options
        .where((ele) => ele.printPackingList)
        .map((e) => e.container)
        .toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    var file = await createPackingListPdf(mapPackingList(withItems));
    Printing.sharePdf(bytes: await file.save());
  }

  void _shareLabelPdf() async {
    var toPrint =
        options.where((ele) => ele.printLabel).map((e) => e.container).toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    var file = await createLabelPdf(mapPackingList(withItems));
    Printing.sharePdf(bytes: await file.save());
  }

  void _shareSafetyDatasheets() async {
    var toPrint = options
        .where((ele) => ele.printSafetyDatasheet)
        .map((e) => e.container)
        .toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));
    var safetySheets = withItems
        .flatMapValues((e) => e.signs)
        .expand((element) => element.sdsPath);
    for (FirebaseDocument element in safetySheets) {
      var data = _loadFileFromWeb(element);
      // await Printing.layoutPdf(onLayout: (_) => data);
      await Printing.sharePdf(bytes: await data);
    }
    // return createLabelPdf(mapPackingList(withItems));
  }

  Future<Uint8List> _loadFileFromWeb(FirebaseDocument element) =>
      FirebaseStorage.instance
          .ref(element.url)
          .getData()
          .then((value) => value!);
}
