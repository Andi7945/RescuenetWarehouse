import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/firebase_document.dart';
import 'package:rescuenet_warehouse/pdf/packing_list_mapper.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_label.dart';
import 'package:rescuenet_warehouse/pdf/pdf_creator_summary.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:shared_storage/shared_storage.dart';

import '../models/item.dart';
import '../pdf/summary_mapper.dart';
import '../pdf/pdf_creator_packing_list.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';

shareSummaryPdf(Map<RescueContainer, Map<Item, int>> forContainers,
    BuildContext context) async {
  var formattedDate = _formattedPrintingDate();
  var fileName = "${formattedDate}_summary.pdf";
  _showExportOptions(
      createSummaryPdf(mapForPdf(forContainers)), fileName, context);
}

void sharePackingListPdf(Map<RescueContainer, Map<Item, int>> withItems,
    BuildContext context) async {
  var formattedDate = _formattedPrintingDate();
  for (var list in mapPackingList(withItems)) {
    var fileName = "${formattedDate}_packing_list_${list.containerNo}.pdf";
    _showExportOptions(createPackingListPdf(list), fileName, context);
  }
}

void shareLabelPdf(Map<RescueContainer, Map<Item, int>> withItems,
    BuildContext context) async {
  var formattedDate = _formattedPrintingDate();
  for (var list in mapPackingList(withItems)) {
    var fileName = "${formattedDate}_label_${list.containerNo}.pdf";
    _showExportOptions(createLabelPdf(list), fileName, context);
  }
}

void shareSafetyDatasheets(Map<RescueContainer, Map<Item, int>> withItems,
    BuildContext context) async {
  var safetySheets = withItems
      .flatMapValues((e) => e.signs)
      .expand((element) => element.sdsPath);
  for (FirebaseDocument element in safetySheets) {
    var data = _loadFileFromWeb(element);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => data);
  }
}

Future<Uint8List> _loadFileFromWeb(FirebaseDocument element) =>
    FirebaseStorage.instance.ref(element.url).getData().then((value) => value!);

String _formattedPrintingDate() {
  final DateFormat formatter = DateFormat("y-MM-dd_H-m");
  return formatter.format(DateTime.now());
}

exportFile(Future<pw.Document> doc, String fileName, BuildContext context) {}

void _showExportOptions(
    Future<pw.Document> doc, String fileName, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print'),
                  onTap: () async {
                    await _print(doc, fileName, context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Printed $fileName."),
                    ));
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  leading: const Icon(Icons.save),
                  title: const Text('Save on disc'),
                  onTap: () async {
                    await _saveFileLocally(doc, fileName, context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Saved to $fileName."),
                    ));
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.podcasts),
                title: const Text('Pop'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
}

_print(Future<pw.Document> doc, String fileName, BuildContext context) async {
  Uint8List pdf = await (await doc).save();
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf);
}

_saveFileLocally(
    Future<pw.Document> doc, String fileName, BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Start to save to $fileName. Load pdf."),
  ));
  Uint8List pdf = await (await doc).save();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Start to save to $fileName. PDF loaded, now specific"),
  ));
  bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  if (isIOS) {
    await _saveFileLocallyIos(pdf, fileName);
  } else {
    await _saveFileLocallyAndroid(pdf, fileName, context);
  }
}

_saveFileLocallyIos(Uint8List pdf, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();

  final file = File("${directory.path}/$fileName");
  print("Save to $fileName");
  await file.writeAsBytes(pdf);
}

_saveFileLocallyAndroid(
    Uint8List pdf, String fileName, BuildContext context) async {
  var uri = await _androidUri(context);

  if (uri != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Save to $uri/$fileName"),
    ));
    createFileAsBytes(
      uri,
      mimeType: 'application/pdf',
      displayName: fileName,
      bytes: pdf,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("No uri selected. Abort printing"),
    ));
  }
}

Future<Uri?> _androidUri(BuildContext context) async {
  final uris = await persistedUriPermissions();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Uris allowed (${uris?.length}): $uris"),
  ));
  var first = uris?.first.uri ?? await openDocumentTree();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Uri used: $first"),
  ));
  return first;
}