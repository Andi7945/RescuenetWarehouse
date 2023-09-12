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

Future<pw.Page> pageHeaderFooter(pw.Widget Function(int) provideHeader,
        pw.Widget body, pw.Widget Function(int, int) footer) async =>
    pw.MultiPage(
        theme: await basicTheme(),
        pageFormat: pageFormatLandscape,
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) => [body],
        header: (ctxt) => provideHeader(ctxt.pageNumber),
        footer: (ctxt) => footer(ctxt.pageNumber, ctxt.pagesCount));

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

pw.Widget Function(int, int) footerFn(String name) =>
    (int num, int max) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text("$name - page $num / $max"));

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

Future<pw.Widget> loadImage(String path,
    [double? width, double? height]) async {
  if (path.isEmpty) return Future.value(pw.Container());
  var provider = path.startsWith("http")
      ? _loadWebImage(path)
      : path.endsWith(".jpg")
          ? _loadImageFromFile(path)
          : _loadImageFromAssets(path);
  return pw.Image(await provider, width: width, height: height);
}

Future<ImageProvider> _loadWebImage(String path) async => networkImage(path);

Future<ImageProvider> _loadImageFromAssets(String path) async =>
    await imageFromAssetBundle('assets/images/$path');

Future<ImageProvider> _loadImageFromFile(String path) async {
  Uint8List x = File(path).readAsBytesSync();
  return pw.MemoryImage(x);
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

Future<List<pw.Widget>> dangerousGoodsLabels(
    List<PackingDangerousGood> goods) async {
  return dangerousGoods(
      goods,
      (ws) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: ws));
}

Future<List<pw.Widget>> dangerousGoodsPackingList(
    List<PackingDangerousGood> goods) async {
  return dangerousGoods(
      goods,
      (ws) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: ws));
}

Future<List<pw.Widget>> dangerousGoods(List<PackingDangerousGood> goods,
    pw.Widget Function(List<pw.Widget> ws) fn) async {
  if (goods.isEmpty) {
    return [_noDangerousGoods()];
  }
  var futures = goods.map((good) => _perGood(good, fn));
  return Future.wait(futures);
}

Future<Widget> _perGood(PackingDangerousGood good,
    pw.Widget Function(List<pw.Widget> ws) renderFn) async {
  var g = await _dangerousGood(good);
  return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(4.0),
      child: renderFn(g));
}

pw.Widget _noDangerousGoods() =>
    pw.Table(children: [smallLabelFatValueRow("Dangerous goods: ", "No")]);

Future<List<pw.Widget>> _dangerousGood(PackingDangerousGood good) async =>
    [_dangerousGoodsTable(good), await loadImage(good.imagePath, 80, 80)];

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
