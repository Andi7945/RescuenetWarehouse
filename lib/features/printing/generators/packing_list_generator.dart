import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

import 'common/pdf_base_widgets.dart';
import 'common/pdf_header_builder.dart';

/// Convert Flutter color int to hex string for PDF
String _colorToHex(int color) {
  return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Generate a packing list PDF document
Future<pw.Document> generatePackingListPdf(
  PackingList packingList,
  PrintContext context,
) async {
  final pdf = pw.Document();
  final page = await _buildPage(packingList, context);
  pdf.addPage(page);
  return pdf;
}

/// Build the complete page with header, body, and footer
Future<pw.Page> _buildPage(PackingList list, PrintContext context) async {
  final header = await _buildHeader(list, context);
  final body = _buildBody(list);
  final footer = buildFooter('Packing list');

  // Check if we need additional dangerous goods section
  final goods = await dangerousGoodsPackingList(list.dangerousGoods);
  final hasAdditionalGoods = goods.length > 1;

  return pw.MultiPage(
    theme: await basicTheme(),
    pageFormat: pageFormatLandscape,
    orientation: pw.PageOrientation.landscape,
    build: (pw.Context context) => [
      // Add additional dangerous goods grid if any (after the first one in header)
      if (hasAdditionalGoods) ...[
        _buildDangerousGoodsGrid(goods.skip(1).toList()),
        pw.SizedBox(height: 8),
      ],
      body,
    ],
    header: (ctxt) => header,
    footer: (ctxt) => footer(ctxt.pageNumber, ctxt.pagesCount),
  );
}

/// Build the header with summary and dangerous goods
Future<pw.Widget> _buildHeader(PackingList list, PrintContext context) async {
  final leftColumn = _buildLeftColumn(list);
  final dangerousGoods = await dangerousGoodsPackingList(list.dangerousGoods);
  final rightSide = dangerousGoods.isNotEmpty ? dangerousGoods.first : null;
  return buildHeaderRow(leftColumn, rightSide, context);
}

/// Build grid from dangerous goods widgets
pw.Widget _buildDangerousGoodsGrid(List<pw.Widget> additionalGoods) {
  List<pw.Widget> rows = [];
  for (var i = 0; i < additionalGoods.length; i += 2) {
    rows.add(_buildGridRow(additionalGoods, i));
    rows.add(pw.SizedBox(height: 8));
  }

  return pw.Column(children: rows);
}

/// Build a single row in the dangerous goods grid
pw.Widget _buildGridRow(List<pw.Widget> goods, int idx) {
  var left = pw.Flexible(child: goods[idx]);
  var right = goods.length > (idx + 1)
      ? pw.Flexible(child: goods[idx + 1])
      : pw.Flexible(child: pw.Container());
  return pw.Row(children: [left, pw.SizedBox(width: 8), right]);
}

/// Build the left column with summary table and value boxes
pw.Widget _buildLeftColumn(PackingList list) {
  final DateFormat formatter = DateFormat("MMMM '' yy");
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      summaryTable(_summaryRows(list)),
      pw.Row(
        children: [
          valueBox("Destination:", list.destination),
          valueBox(
            "Seq. build prio:",
            list.sequentialBuild.displayName,
            12.0,
            PdfColor.fromHex(_colorToHex(list.sequentialBuild.color.value)),
          ),
          valueBox(
            "Expiration:",
            list.expirationDate != null
                ? formatter.format(list.expirationDate!)
                : "",
          ),
        ],
      ),
    ],
  );
}

/// Build summary rows for the packing list
List<pw.TableRow> _summaryRows(PackingList list) => [
  pw.TableRow(children: [bigger("Packing list"), pw.Container()]),
  ...summaryRows(list),
];

/// Build the main table body with items
pw.Widget _buildBody(PackingList list) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5),
    columnWidths: {
      0: const pw.FixedColumnWidth(128),
      1: const pw.FixedColumnWidth(200),
      2: const pw.FixedColumnWidth(112),
      3: const pw.FixedColumnWidth(104),
      4: const pw.FixedColumnWidth(104),
      5: const pw.FixedColumnWidth(112),
      6: const pw.FixedColumnWidth(136),
      7: const pw.FixedColumnWidth(184),
      8: const pw.FixedColumnWidth(416),
    },
    children: [_headlines(), ...list.items.map(_line), _sumRow(list.items)],
  );
}

/// Build the table header row
pw.TableRow _headlines() => pw.TableRow(
  repeat: true,
  children: [
    tableHeadline("Item"),
    tableHeadline("Description"),
    tableHeadline("Amount"),
    tableHeadline("Price each"),
    tableHeadline("Price total"),
    tableHeadline("Weight total"),
    tableHeadline("Expiration date"),
    tableHeadline("Dangerous goods"),
    tableHeadline("Remarks"),
  ],
);

final DateFormat _dateFormatter = DateFormat('MMM d, yyyy');

/// Build a single item row
pw.TableRow _line(PackingItem item) => pw.TableRow(
  children: [
    tableCell(item.name),
    tableCell(item.description),
    tableCell(item.amount.toStringAsFixed(0)),
    tableCell("€${item.piecePrice.toStringAsFixed(0)},-"),
    tableCell("€${(item.piecePrice * item.amount).toStringAsFixed(0)},-"),
    tableCell("${item.weightTotal} kg"),
    tableCell(
      item.expirationDate != null
          ? _dateFormatter.format(item.expirationDate!)
          : "",
    ),
    tableCell(item.dangerousGoods),
    tableCell(item.remarks),
  ],
);

/// Build the summary row with total price
pw.TableRow _sumRow(List<PackingItem> items) {
  var summed = items
      .fold(
        0.0,
        (previousValue, itm) => previousValue + (itm.amount * itm.piecePrice),
      )
      .toStringAsFixed(0);
  return pw.TableRow(
    children: [
      tableCell("Combined:"),
      tableCell(""),
      tableCell(""),
      tableCell(""),
      tableCell("€$summed,-"),
      tableCell(""),
      tableCell(""),
      tableCell(""),
      tableCell(""),
    ],
  );
}
