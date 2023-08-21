import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import 'packing_dangerous_good.dart';
import 'packing_list.dart';

smallText(String text, [PdfColor? backgroundColor]) => pw.Text(text,
    style: pw.TextStyle(
        fontSize: 10.0, background: pw.BoxDecoration(color: backgroundColor)));

var empty = pw.SizedBox(height: 10);

tableHeadline(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(2.0),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 10.0, fontWeight: pw.FontWeight.bold)));

tableCell(String text, [PdfColor? textBackgroundColor]) => pw.Padding(
    padding: const pw.EdgeInsets.all(2.0),
    child: smallText(text, textBackgroundColor));

const double inch = 72.0;
const double cm = inch / 2.54;

const pageFormatLandscape =
    PdfPageFormat(29.7 * cm, 21.0 * cm, marginAll: 1.0 * cm);
const pageFormatLabels = PdfPageFormat(14.8 * cm, 10.51 * cm, marginAll: 10);

Future<pw.ThemeData> basicTheme() async => ThemeData.withFont(
      base: Font.ttf(await rootBundle
          .load("assets/fonts/liberation_sans/LiberationSans-Regular.ttf")),
      bold: Font.ttf(await rootBundle
          .load("assets/fonts/liberation_sans/LiberationSans-Bold.ttf")),
      italic: Font.ttf(await rootBundle
          .load("assets/fonts/liberation_sans/LiberationSans-Italic.ttf")),
      boldItalic: Font.ttf(await rootBundle
          .load("assets/fonts/liberation_sans/LiberationSans-BoldItalic.ttf")),
    );

Future<pw.Page> pageHeaderFooter(
        pw.Widget header, pw.Widget body, pw.Widget footer) async =>
    pw.MultiPage(
        theme: await basicTheme(),
        pageFormat: pageFormatLandscape,
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) => [body],
        header: (ctxt) => header,
        footer: (ctxt) => footer);

Future<pw.Page> basicPage(pw.Widget w) async => pw.MultiPage(
      theme: await basicTheme(),
      pageFormat: pageFormatLandscape,
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) => [w],
    );

Future<void> saveAndPrint(pw.Document pdf) async {
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/example.pdf");
  print("Save to ${output.path}/example.pdf");
  await file.writeAsBytes(await pdf.save());
}

summaryTable(List<pw.TableRow> rows) {
  return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(4.0),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      child: pw.Table(children: rows, columnWidths: {
        0: const pw.FixedColumnWidth(160),
        1: const pw.FixedColumnWidth(220),
      }));
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

Future<pw.Image> loadImage(String path) async => path.endsWith(".jpg")
    ? _loadImageFromFile(path)
    : _loadImageFromAssets(path);

Future<pw.Image> _loadImageFromAssets(String path) async =>
    pw.Image(await imageFromAssetBundle('assets/images/$path'));

Future<pw.Image> _loadImageFromFile(String path) async {
  Uint8List x = File(path).readAsBytesSync();
  return pw.Image(pw.MemoryImage(x));
}

List<pw.TableRow> summaryRows(PackingList list) {
  return [
    smallLabelFatValueRow("Container no:", "${list.containerNo}"),
    smallRow("Type container:", list.containerType),
    blankRow(),
    smallRow("Name:", list.containerName),
    smallRow("Description:", list.containerDescription),
    blankRow(),
    smallLabelFatValueRow(
        "Weight:", "${list.totalWeight.toStringAsFixed(2)} kg"),
    blankRow(),
  ];
}

pw.Widget valueBox(String label, String value,
        [double? paddingRight, PdfColor? backgroundColor]) =>
    pw.Padding(
        padding: pw.EdgeInsets.only(right: paddingRight ?? 12.0, top: 12.0),
        child: pw.Container(
            width: 90,
            height: 40,
            padding: const pw.EdgeInsets.all(2.0),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
              color: backgroundColor,
            ),
            child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4.0),
                      child: pw.Text(label,
                          style: const pw.TextStyle(fontSize: 10.0))),
                  pw.Text(value,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14))
                ])));

Future<pw.Widget> dangerousGoodsLabels(List<PackingDangerousGood> goods) async {
  return dangerousGoods(
      goods,
      (ws) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: ws));
}

Future<pw.Widget> dangerousGoodsPackingList(
    List<PackingDangerousGood> goods) async {
  return dangerousGoods(
      goods,
      (ws) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: ws));
}

Future<pw.Widget> dangerousGoods(List<PackingDangerousGood> goods,
    pw.Widget Function(List<pw.Widget> ws) fn) async {
  List<pw.Widget> w =
      goods.isEmpty ? [_noDangerousGoods()] : await _dangerousGood(goods.first);
  return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(4.0),
      child: fn(w));
}

pw.Widget _noDangerousGoods() =>
    pw.Table(children: [smallLabelFatValueRow("Dangerous goods:", "No")]);

Future<List<pw.Widget>> _dangerousGood(PackingDangerousGood good) async =>
    [_dangerousGoodsTable(good), await loadImage(good.imagePath)];

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
