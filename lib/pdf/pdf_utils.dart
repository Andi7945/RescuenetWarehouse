import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

smallText(String text) =>
    pw.Text(text, style: const pw.TextStyle(fontSize: 10.0));

var empty = pw.SizedBox(height: 10);

tableHeadline(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(2.0),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 10.0, fontWeight: pw.FontWeight.bold)));

tableCell(String text) =>
    pw.Padding(padding: const pw.EdgeInsets.all(2.0), child: smallText(text));

Future<pw.Document> basicPdf(pw.Widget w) async {
  final pdf = pw.Document();

  const double inch = 72.0;
  const double cm = inch / 2.54;

  pdf.addPage(
    pw.Page(
      pageFormat:
          const PdfPageFormat(21.0 * cm, 29.7 * cm, marginAll: 1.0 * cm),
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) => w,
    ),
  );
  return pdf;
}

Future<void> saveAndPrint(pw.Document pdf) async {
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/example.pdf");
  print("Save to ${output.path}/example.pdf");
  await file.writeAsBytes(await pdf.save());
}

summaryTable(List<pw.TableRow> rows) {
  return pw.Container(
      padding: const pw.EdgeInsets.all(4.0),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      child: pw.Table(children: rows));
}

bigger(String text) => pw.Text(text, style: const pw.TextStyle(fontSize: 16.0));

biggerAndFat(String text) => pw.Text(text,
    style: pw.TextStyle(fontSize: 16.0, fontWeight: pw.FontWeight.bold));

pw.TableRow smallRow(String label, String value) => pw.TableRow(
    verticalAlignment: pw.TableCellVerticalAlignment.bottom,
    children: [smallText(label), smallText(value)]);

pw.TableRow smallLabelFatValueRow(String label, String value) => pw.TableRow(
    verticalAlignment: pw.TableCellVerticalAlignment.bottom,
    children: [smallText(label), biggerAndFat(value)]);

pw.TableRow blankRow() => pw.TableRow(children: [empty, pw.Container()]);


Future<pw.Image> loadImage(String path) async {
  final img = await rootBundle.load(path);
  final imageBytes = img.buffer.asUint8List();
  pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));
  return image1;
}