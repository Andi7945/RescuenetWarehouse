import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/summary_container.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';
import 'package:intl/intl.dart';

createPdf(SummaryPdf summary) async {
  final pdf = pw.Document();

  var body = await _body(summary);

  const double inch = 72.0;
  const double cm = inch / 2.54;

  pdf.addPage(
    pw.Page(
      pageFormat:
          const PdfPageFormat(21.0 * cm, 29.7 * cm, marginAll: 1.0 * cm),
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) => body,
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/example.pdf");
  print("Save to ${output.path}/example.pdf");
  await file.writeAsBytes(await pdf.save());
}

_body(SummaryPdf summary) async {
  var headerRow = await _headerRow(summary.list);
  return pw.Column(children: [
    headerRow,
    pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16.0),
        child: _entries(summary.containers))
  ]);
}

_headerRow(SummaryList summaryList) async {
  var logo = await _logo();
  return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Expanded(child: _summary(summaryList), flex: 5),
    pw.Expanded(
        child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
            child: _exec()),
        flex: 2),
    pw.Expanded(child: logo, flex: 3)
  ]);
}

_logo() async {
  final img = await rootBundle.load('assets/images/LogoRN.png');
  final imageBytes = img.buffer.asUint8List();
  pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));
  return image1;
}

_exec() => pw.Container(
    padding: const pw.EdgeInsets.all(4.0),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _smallText("backoffice@rescuenet.net"),
          _smallText("+31-6-14419988"),
          _empty,
          _smallText("Printed by: GJP"),
          _smallText("Date: ${_now()}"),
          _empty,
        ]));

String _now() {
  final DateFormat formatter = DateFormat.yMMMMd('en_US');
  return formatter.format(DateTime.now());
}

_smallText(String text) =>
    pw.Text(text, style: const pw.TextStyle(fontSize: 10.0));

var _empty = pw.SizedBox(height: 10);

_summary(SummaryList summaryList) {
  return pw.Container(
      padding: const pw.EdgeInsets.all(4.0),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      child: pw.Table(children: [
        pw.TableRow(children: [_bigger("Summary list"), pw.Container()]),
        pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.bottom,
            children: [
              _smallText("Total amount of containers:"),
              _biggerAndFat(summaryList.count)
            ]),
        pw.TableRow(children: [
          _smallText("Amount per type of containers:"),
          pw.Container()
        ]),
        ...summaryList.amountPerType.entries.map((e) =>
            pw.TableRow(children: [_smallText(e.key), _smallText(e.value)])),
        pw.TableRow(children: [_empty, pw.Container()]),
        pw.TableRow(children: [
          _smallText("Total value"),
          _smallText("EUR ${summaryList.totalValue},-")
        ]),
        pw.TableRow(children: [_empty, pw.Container()]),
        pw.TableRow(children: [
          _smallText("Total weight"),
          _biggerAndFat("${summaryList.totalWeight.toStringAsFixed(2)} kg"),
        ]),
        pw.TableRow(children: [_empty, pw.Container()]),
      ]));
}

_bigger(String text) =>
    pw.Text(text, style: const pw.TextStyle(fontSize: 16.0));

_biggerAndFat(String text) => pw.Text(text,
    style: pw.TextStyle(fontSize: 16.0, fontWeight: pw.FontWeight.bold));

_entries(List<SummaryContainer> container) =>
    pw.Table(border: pw.TableBorder.all(width: 0.5), columnWidths: {
      0: const pw.FixedColumnWidth(120),
      1: const pw.FixedColumnWidth(146),
      2: const pw.FixedColumnWidth(204),
      3: const pw.FixedColumnWidth(110),
      4: const pw.FixedColumnWidth(104),
      5: const pw.FixedColumnWidth(104),
      6: const pw.FixedColumnWidth(118),
      7: const pw.FixedColumnWidth(263),
      8: const pw.FixedColumnWidth(85),
      9: const pw.FixedColumnWidth(154),
      10: const pw.FixedColumnWidth(178)
    }, children: [
      _headline(),
      ..._lines(container)
    ]);

_headline() => pw.TableRow(children: [
      _tableHeadline("Container nr"),
      _tableHeadline("Name"),
      _tableHeadline("Description"),
      _tableHeadline("Type of container"),
      _tableHeadline("Value"),
      _tableHeadline("Weight"),
      _tableHeadline("Expiration date"),
      _tableHeadline("Dangerous goods"),
      _tableHeadline("Cold chain"),
      _tableHeadline("Module destination"),
      _tableHeadline("Sequential build priority"),
    ]);

_tableHeadline(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(2.0),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 10.0, fontWeight: pw.FontWeight.bold)));

_tableCell(String text) =>
    pw.Padding(padding: const pw.EdgeInsets.all(2.0), child: _smallText(text));

_lines(List<SummaryContainer> container) => container.map(_line).toList();

pw.TableRow _line(SummaryContainer container) => pw.TableRow(children: [
      _tableCell(container.containerNr),
      _tableCell(container.name),
      _tableCell(container.description),
      _tableCell(container.type),
      _tableCell("EUR ${container.value},-"),
      _tableCell("${container.weight.toStringAsFixed(2)} kg"),
      _tableCell(container.expirationDate),
      _tableCell(container.dangerousGoods),
      _tableCell(container.coldChain),
      _tableCell(container.moduleDestination),
      _tableCell(container.sequentialBuildPriority),
    ]);
