import 'package:pdf/pdf.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_header_row.dart';
import 'pdf_utils.dart';

import 'package:intl/intl.dart';

Future<pw.Document> createPackingListPdf(List<PackingList> lists) async {
  final pdf = pw.Document();
  var pages = lists.map(_body).map((e) async => await basicPage(await e));
  var builded = await Future.wait(pages);
  for (var page in builded) {
    pdf.addPage(page);
  }
  return pdf;
}

Future<pw.Column> _body(PackingList list) async {
  var upperLeft = _upperLeft(list);
  var rightChild = await dangerousGoodsPackingList(list.dangerousGoods);
  var row = await headerRow(upperLeft, rightChild);
  return pw.Column(
      children: [row, pw.SizedBox(height: 24), _packingTable(list)]);
}

_upperLeft(PackingList list) {
  DateFormat formatter = DateFormat("MMMM '' yy");
  return pw.Column(children: [
    summaryTable(_summaryRows(list)),
    pw.Row(children: [
      valueBox("Destination:", list.destination),
      valueBox("Seq. build prio:", list.sequentialBuild.displayName, 12.0,
          PdfColor.fromInt(list.sequentialBuild.color.value)),
      valueBox(
          "Expiration:",
          list.expirationDate != null
              ? formatter.format(list.expirationDate!)
              : ""),
    ])
  ]);
}

_summaryRows(PackingList list) => [
      pw.TableRow(children: [bigger("Packing list"), pw.Container()]),
      ...summaryRows(list)
    ];

pw.Widget _packingTable(PackingList list) =>
    pw.Table(border: pw.TableBorder.all(width: 0.5), columnWidths: {
      0: const pw.FixedColumnWidth(128),
      1: const pw.FixedColumnWidth(200),
      2: const pw.FixedColumnWidth(112),
      3: const pw.FixedColumnWidth(104),
      4: const pw.FixedColumnWidth(104),
      5: const pw.FixedColumnWidth(112),
      6: const pw.FixedColumnWidth(136),
      7: const pw.FixedColumnWidth(184),
      8: const pw.FixedColumnWidth(416),
    }, children: [
      _headlines(),
      ...list.items.map(_line),
      _sumRow(list.items)
    ]);

pw.TableRow _headlines() => pw.TableRow(children: [
      tableHeadline("Item"),
      tableHeadline("Description"),
      tableHeadline("Amount"),
      tableHeadline("Price each"),
      tableHeadline("Price total"),
      tableHeadline("Weight total"),
      tableHeadline("Expiration date"),
      tableHeadline("Dangerous goods"),
      tableHeadline("Remarks"),
    ]);

final DateFormat formatter = DateFormat('MMM d, yyyy');

pw.TableRow _line(PackingItem item) => pw.TableRow(children: [
      tableCell(item.name),
      tableCell(item.description),
      tableCell(item.amount.toStringAsFixed(0)),
      tableCell("€${item.piecePrice.toStringAsFixed(0)},-"),
      tableCell("€${(item.piecePrice * item.amount).toStringAsFixed(0)},-"),
      tableCell("${item.weightTotal} kg"),
      tableCell(item.expirationDate != null
          ? formatter.format(item.expirationDate!)
          : ""),
      tableCell(item.dangerousGoods),
      tableCell(item.remarks),
    ]);

pw.TableRow _sumRow(List<PackingItem> items) {
  var summed = items
      .fold(0.0,
          (previousValue, itm) => previousValue + (itm.amount * itm.piecePrice))
      .toStringAsFixed(0);
  return pw.TableRow(children: [
    tableCell("Combined:"),
    tableCell(""),
    tableCell(""),
    tableCell(""),
    tableCell("€$summed,-"),
    tableCell(""),
    tableCell(""),
    tableCell(""),
    tableCell(""),
  ]);
}
