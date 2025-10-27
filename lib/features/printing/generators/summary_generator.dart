import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/summary_container.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';

import 'common/pdf_base_widgets.dart';
import 'common/pdf_header_builder.dart';

/// Convert Flutter color int to hex string for PDF
String _colorToHex(int color) {
  return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Generate summary PDF document
Future<pw.Document> generateSummaryPdf(
  SummaryPdf summary,
  PrintContext context,
) async {
  final pdf = pw.Document();
  final page = await _buildPage(summary, context);
  pdf.addPage(page);
  return pdf;
}

/// Build the complete page with header, body, and footer
Future<pw.Page> _buildPage(SummaryPdf summary, PrintContext context) async {
  final body = _buildBody(summary.containers);
  final footer = buildFooter('Summary');

  // Pre-build headers for all pages
  final fullHeader = await _buildFullHeader(summary.list, context);
  final smallHeader = await _buildSmallHeader(context);

  return pw.MultiPage(
    theme: await basicTheme(),
    pageFormat: pageFormatLandscape,
    orientation: pw.PageOrientation.landscape,
    build: (pw.Context context) => [body],
    header: (ctxt) => ctxt.pageNumber == 1 ? fullHeader : smallHeader,
    footer: (ctxt) => footer(ctxt.pageNumber, ctxt.pagesCount),
  );
}

/// Build full header for first page with all summary details
Future<pw.Widget> _buildFullHeader(
  SummaryList summaryList,
  PrintContext context,
) async {
  final leftColumn = summaryTable(_buildSummaryRows(summaryList));
  return buildHeaderRow(leftColumn, null, context);
}

/// Build small header for subsequent pages
Future<pw.Widget> _buildSmallHeader(PrintContext context) async {
  final leftColumn = summaryTable([
    pw.TableRow(children: [bigger("Summary list"), pw.Container()]),
  ]);
  return buildHeaderRow(leftColumn, null, context);
}

/// Build summary rows with all the totals
List<pw.TableRow> _buildSummaryRows(SummaryList summaryList) {
  return [
    pw.TableRow(children: [bigger("Summary list"), pw.Container()]),
    smallLabelFatValueRow("Total amount of containers:", summaryList.count),
    smallRow("Amount per type of containers:", ""),
    ...summaryList.amountPerType.entries.map((e) => smallRow(e.key, e.value)),
    blankRow(),
    smallRow("Total value", "€${summaryList.totalValue},-"),
    blankRow(),
    smallLabelFatValueRow(
      "Total weight",
      "${summaryList.totalWeight.toStringAsFixed(2)} kg",
    ),
    blankRow(),
  ];
}

/// Build the main table body with containers
pw.Widget _buildBody(List<SummaryContainer> containers) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5),
    columnWidths: {
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
      10: const pw.FixedColumnWidth(178),
    },
    children: [_headline(), ..._lines(containers)],
  );
}

/// Build the table header row
pw.TableRow _headline() => pw.TableRow(
  children: [
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
  ],
);

/// Build all container rows
List<pw.TableRow> _lines(List<SummaryContainer> containers) =>
    containers.map(_line).toList();

/// Build a single container row
pw.TableRow _line(SummaryContainer container) => pw.TableRow(
  children: [
    tableCell(container.containerNr.toStringAsFixed(0)),
    tableCell(container.name),
    tableCell(container.description),
    tableCell(container.type),
    tableCell("€${container.value},-"),
    tableCell("${container.weight.toStringAsFixed(2)} kg"),
    tableCell(container.expirationDate),
    tableCell(container.dangerousGoods),
    tableCell(container.coldChain),
    tableCell(container.moduleDestination),
    tableCell(
      container.sequentialBuild.displayName,
      PdfColor.fromHex(_colorToHex(container.sequentialBuild.color.value)),
    ),
  ],
);
