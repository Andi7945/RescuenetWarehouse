import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/summary_container.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';

import 'pdf_header_row.dart';
import 'pdf_utils.dart';

Future<pw.Document> createSummaryPdf(SummaryPdf summary) async {
  final pdf = pw.Document();
  var page = await basicPage(await _body(summary));
  pdf.addPage(page);
  return pdf;
}

Future<pw.Column> _body(SummaryPdf summary) async {
  var row = await headerRow(summaryTable(_summaryRows(summary.list)));
  return pw.Column(children: [
    row,
    pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16.0),
        child: _entries(summary.containers))
  ]);
}

List<pw.TableRow> _summaryRows(SummaryList summaryList) {
  return [
    pw.TableRow(children: [bigger("Summary list"), pw.Container()]),
    smallLabelFatValueRow("Total amount of containers:", summaryList.count),
    smallRow("Amount per type of containers:", ""),
    ...summaryList.amountPerType.entries.map((e) => smallRow(e.key, e.value)),
    blankRow(),
    smallRow("Total value", "€${summaryList.totalValue},-"),
    blankRow(),
    smallLabelFatValueRow(
        "Total weight", "${summaryList.totalWeight.toStringAsFixed(2)} kg"),
    blankRow(),
  ];
}

pw.Table _entries(List<SummaryContainer> container) =>
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

pw.TableRow _headline() => pw.TableRow(children: [
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

List<pw.TableRow> _lines(List<SummaryContainer> container) =>
    container.map(_line).toList();

pw.TableRow _line(SummaryContainer container) => pw.TableRow(children: [
      tableCell(container.containerNr),
      tableCell(container.name),
      tableCell(container.description),
      tableCell(container.type),
      tableCell("€${container.value},-"),
      tableCell("${container.weight.toStringAsFixed(2)} kg"),
      tableCell(container.expirationDate),
      tableCell(container.dangerousGoods),
      tableCell(container.coldChain),
      tableCell(container.moduleDestination),
      tableCell(container.sequentialBuild.displayName,
          PdfColor.fromInt(container.sequentialBuild.color.value)),
    ]);
