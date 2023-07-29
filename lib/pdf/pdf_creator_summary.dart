import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/summary_container.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';

import 'pdf_header_row.dart';
import 'pdf_utils.dart';

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
  var row = await headerRow(_summary(summary.list));
  return pw.Column(children: [
    row,
    pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16.0),
        child: _entries(summary.containers))
  ]);
}

_summary(SummaryList summaryList) {
  return pw.Container(
      padding: const pw.EdgeInsets.all(4.0),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      child: pw.Table(children: [
        pw.TableRow(children: [_bigger("Summary list"), pw.Container()]),
        pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.bottom,
            children: [
              smallText("Total amount of containers:"),
              _biggerAndFat(summaryList.count)
            ]),
        pw.TableRow(children: [
          smallText("Amount per type of containers:"),
          pw.Container()
        ]),
        ...summaryList.amountPerType.entries.map((e) =>
            pw.TableRow(children: [smallText(e.key), smallText(e.value)])),
        pw.TableRow(children: [empty, pw.Container()]),
        pw.TableRow(children: [
          smallText("Total value"),
          smallText("EUR ${summaryList.totalValue},-")
        ]),
        pw.TableRow(children: [empty, pw.Container()]),
        pw.TableRow(children: [
          smallText("Total weight"),
          _biggerAndFat("${summaryList.totalWeight.toStringAsFixed(2)} kg"),
        ]),
        pw.TableRow(children: [empty, pw.Container()]),
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
      tableHeadline("Container nr"),
      tableHeadline("Name"),
      tableHeadline("Description"),
      tableHeadline("Type of container"),
      tableHeadline("Value"),
      tableHeadline("Weight"),
      tableHeadline("Expiration date"),
      tableHeadline("Dangerous goods"),
      tableHeadline("Cold chain"),
      tableHeadline("Module destination"),
      tableHeadline("Sequential build priority"),
    ]);

_lines(List<SummaryContainer> container) => container.map(_line).toList();

pw.TableRow _line(SummaryContainer container) => pw.TableRow(children: [
      tableCell(container.containerNr),
      tableCell(container.name),
      tableCell(container.description),
      tableCell(container.type),
      tableCell("EUR ${container.value},-"),
      tableCell("${container.weight.toStringAsFixed(2)} kg"),
      tableCell(container.expirationDate),
      tableCell(container.dangerousGoods),
      tableCell(container.coldChain),
      tableCell(container.moduleDestination),
      tableCell(container.sequentialBuildPriority),
    ]);
