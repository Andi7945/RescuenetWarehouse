import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_header_row.dart';
import 'pdf_utils.dart';

import 'package:intl/intl.dart';

createPackingListPdf(PackingList list) async {
  var body = await _body(list);
  await saveAndPrint(await basicPdf(body));
}

Future<pw.Column> _body(PackingList list) async {
  var upperLeft = _upperLeft(list);
  var rightChild = await _dangerousGoods(list.dangerousGoods.first);
  var row = await headerRow(upperLeft, rightChild);
  return pw.Column(
      children: [row, pw.SizedBox(height: 24), _packingTable(list)]);
}

_upperLeft(PackingList list) {
  DateFormat formatter = DateFormat("MMMM '' yy");
  return pw.Column(children: [
    summaryTable(_summaryRows(list)),
    pw.Row(children: [
      _valueBox("Destination:", list.destination),
      _valueBox("Seq. build prio:", list.sequentialBuildPrio),
      _valueBox("Expiration:", formatter.format(list.expirationDate)),
    ])
  ]);
}

List<pw.TableRow> _summaryRows(PackingList list) {
  return [
    pw.TableRow(children: [bigger("Packing list"), pw.Container()]),
    smallLabelFatValueRow("Container no:", list.containerNo),
    smallRow("Type container:", list.containerType),
    blankRow(),
    smallRow("Name:", list.containerName),
    smallRow("Description:", list.containerDescription),
    blankRow(),
    blankRow(),
    smallLabelFatValueRow("Weight:", "${list.totalWeight} kg"),
    blankRow(),
  ];
}

pw.Widget _valueBox(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(right: 12.0, top: 12.0),
    child: pw.Container(
        width: 92,
        height: 40,
        padding: const pw.EdgeInsets.all(2.0),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
        child: pw
            .Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4.0),
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 10.0))),
          pw.Text(value,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))
        ])));

Future<pw.Widget> _dangerousGoods(PackingDangerousGood good) async {
  return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(4.0),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _dangerousGoodsTable(good),
            await loadImage('assets/images/${good.imagePath}')
          ]));
}

pw.Widget _dangerousGoodsTable(PackingDangerousGood good) =>
    pw.Table(children: [
      smallLabelFatValueRow("Dangerous goods:", "Yes"),
      smallRow("Type:", good.dangerType),
      smallRow("IATA ID:", good.iataId),
      smallRow("Proper shipping name:", good.properShippingName),
      smallRow("Max weight PAX:", "${good.maxWeightPAX.toStringAsFixed(1)} kg"),
      smallRow(
          "Max weight Cargo:", "${good.maxWeightCargo.toStringAsFixed(1)} kg"),
      smallRow("Remarks:", good.remarks),
    ]);

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
      tableCell("EUR ${item.piecePrice.toStringAsFixed(0)},-"),
      tableCell("EUR ${(item.piecePrice * item.amount).toStringAsFixed(0)},-"),
      tableCell("${item.weightTotal} kg"),
      tableCell(item.expirationDate != null
          ? formatter.format(item.expirationDate!)
          : ""),
      tableCell(item.dangerousGoods),
      tableCell(item.remarks),
    ]);

pw.TableRow _sumRow(List<PackingItem> items) {
  var summed = items.fold(0.0,
      (previousValue, itm) => previousValue + (itm.amount * itm.piecePrice));
  return pw.TableRow(children: [
    tableCell("Combined:"),
    tableCell(""),
    tableCell(""),
    tableCell(""),
    tableCell("EUR $summed,-"),
    tableCell(""),
    tableCell(""),
    tableCell(""),
    tableCell(""),
  ]);
}
