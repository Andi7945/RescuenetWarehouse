import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
import 'package:rescuenet_warehouse/pdf/packing_list_mapper.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_label.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_summary.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:shared_storage/shared_storage.dart';

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

    options.sort((a, b) => a.container.number.compareTo(b.container.number));

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

  Widget _summaryButton() => FilledButton(
      onPressed: () async {
        await _shareSummaryPdf();
      },
      child: RescueText.normal("Print final summary"));

  _shareSummaryPdf() async {
    var forContainers = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => ele.key.isReady && ele.key.toDeploy));

    var formattedDate = _formattedPrintingDate();
    var fileName = "${formattedDate}_summary.pdf";
    _saveFileLocally(createSummaryPdf(mapForPdf(forContainers)), fileName);
  }

  void _sharePackingListPdf() async {
    var toPrint = options
        .where((ele) => ele.printPackingList)
        .map((e) => e.container)
        .toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));

    var formattedDate = _formattedPrintingDate();
    for (var list in mapPackingList(withItems)) {
      var fileName = "${formattedDate}_packing_list_${list.containerNo}.pdf";
      _saveFileLocally(createPackingListPdf(list), fileName);
    }
    // Printing.sharePdf(bytes: await file.save());
  }

  void _shareLabelPdf() async {
    var toPrint =
        options.where((ele) => ele.printLabel).map((e) => e.container).toList();
    var withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));

    var formattedDate = _formattedPrintingDate();
    for (var list in mapPackingList(withItems)) {
      var fileName = "${formattedDate}_label_${list.containerNo}.pdf";
      _saveFileLocally(createLabelPdf(list), fileName);
    }
    // Printing.sharePdf(bytes: await file.save());
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
      await Printing.sharePdf(bytes: await data);
    }
  }

  Future<Uint8List> _loadFileFromWeb(FirebaseDocument element) =>
      FirebaseStorage.instance
          .ref(element.url)
          .getData()
          .then((value) => value!);

  String _formattedPrintingDate() {
    final DateFormat formatter = DateFormat("y-MM-dd_H-m");
    return formatter.format(DateTime.now());
  }

  _saveFileLocally(Future<pw.Document> doc, String fileName) async {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      _saveFileLocallyIos(doc, fileName);
    } else {
      _saveFileLocallyAndroid(doc, fileName);
    }
  }

  _saveFileLocallyIos(Future<pw.Document> doc, String fileName) async {
    var pdf = await doc;
    final directory = await getApplicationDocumentsDirectory();

    final file = File("${directory.path}/$fileName");
    print("Save to $fileName");
    await file.writeAsBytes(await pdf.save());
  }

  _saveFileLocallyAndroid(Future<pw.Document> doc, String fileName) async {
    var uri = await _androidUri();

    if (uri != null) {
      print("Save to $uri/$fileName");
      createFileAsBytes(
        uri,
        mimeType: 'application/pdf',
        displayName: fileName,
        bytes: Uint8List.fromList(await (await doc).save()),
      );
    } else {
      print("No uri selected. Abort printing");
    }
  }

  Future<Uri?> _androidUri() async {
    final uris = await persistedUriPermissions();
    return uris?.first.uri ?? await openDocumentTree();
  }
}
