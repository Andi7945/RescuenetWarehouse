import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'package:pdf/widgets.dart' as pw;

import 'header_provider.dart';
import 'pdf_utils.dart';

import 'package:intl/intl.dart';

Future<pw.Document> createPackingListPdf(List<PackingList> lists) async {
  final pdf = pw.Document();
  var pages =
      await Future.wait(lists.map((e) => _singlePage(HeaderProvider(), e)));

  for (var page in pages) {
    pdf.addPage(page);
  }
  return pdf;
}

Future<pw.Page> _singlePage(HeaderProvider prov, PackingList list) async =>
    pageHeaderFooter(
        await prov.provideHeader(list), _body(list), footerFn("Packing list"));

pw.Table _body(PackingList list) =>
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

pw.TableRow _headlines() => pw.TableRow(repeat: true, children: [
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
