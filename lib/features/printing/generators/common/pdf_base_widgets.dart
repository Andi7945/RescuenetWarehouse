import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

/// Base PDF widget utilities - pure functions for building PDF components

// Text styles
pw.Widget smallText(String text, [PdfColor? backgroundColor]) => pw.Text(
  text,
  style: pw.TextStyle(
    fontSize: 10.0,
    background: pw.BoxDecoration(color: backgroundColor),
  ),
);

pw.SizedBox empty = pw.SizedBox(height: 10);

pw.Widget tableHeadline(String text) => pw.Padding(
  padding: const pw.EdgeInsets.all(2.0),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: 10.0, fontWeight: pw.FontWeight.bold),
  ),
);

pw.Widget tableCell(String text, [PdfColor? textBackgroundColor]) => pw.Padding(
  padding: const pw.EdgeInsets.all(2.0),
  child: smallText(text, textBackgroundColor),
);

pw.Widget bigger(String text) =>
    pw.Text(text, style: const pw.TextStyle(fontSize: 16.0));

pw.Widget biggerAndFat(String text) => pw.Text(
  text,
  style: pw.TextStyle(fontSize: 16.0, fontWeight: pw.FontWeight.bold),
);

// Page formats
const double inch = 72.0;
const double cm = inch / 2.54;

const pageFormatLandscape = PdfPageFormat(
  29.7 * cm,
  21.0 * cm,
  marginAll: 1.0 * cm,
);
const pageFormatLabels = PdfPageFormat(14.8 * cm, 10.51 * cm, marginAll: 10);

// Theme
Future<pw.ThemeData> basicTheme() async => pw.ThemeData.withFont(
  base: pw.Font.ttf(
    await rootBundle.load(
      "assets/fonts/liberation_sans/LiberationSans-Regular.ttf",
    ),
  ),
  bold: pw.Font.ttf(
    await rootBundle.load(
      "assets/fonts/liberation_sans/LiberationSans-Bold.ttf",
    ),
  ),
  italic: pw.Font.ttf(
    await rootBundle.load(
      "assets/fonts/liberation_sans/LiberationSans-Italic.ttf",
    ),
  ),
  boldItalic: pw.Font.ttf(
    await rootBundle.load(
      "assets/fonts/liberation_sans/LiberationSans-BoldItalic.ttf",
    ),
  ),
);

// Layout components
pw.Widget valueBox(
  String label,
  String value, [
  double? paddingRight,
  PdfColor? backgroundColor,
]) => pw.Padding(
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
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 10.0)),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        ),
      ],
    ),
  ),
);

pw.Widget summaryTable(List<pw.TableRow> rows) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(4.0),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Table(
      children: rows,
      columnWidths: {
        0: const pw.FixedColumnWidth(160),
        1: const pw.FixedColumnWidth(220),
      },
    ),
  );
}

pw.TableRow smallRow(String label, String value) => pw.TableRow(
  verticalAlignment: pw.TableCellVerticalAlignment.bottom,
  children: [smallText(label), smallText(value)],
);

pw.TableRow smallLabelFatValueRow(String label, String value) => pw.TableRow(
  verticalAlignment: pw.TableCellVerticalAlignment.bottom,
  children: [smallText(label), biggerAndFat(value)],
);

pw.TableRow blankRow() => pw.TableRow(children: [empty, pw.Container()]);

// Image loading
Future<pw.Widget> loadImage(
  String path, [
  double? width,
  double? height,
]) async {
  if (path.isEmpty) return Future.value(pw.Container());
  var provider = path.startsWith("http")
      ? _loadWebImage(path)
      : path.endsWith(".jpg")
      ? _loadImageFromFile(path)
      : _loadImageFromAssets(path);
  return pw.Image(await provider, width: width, height: height);
}

Future<pw.ImageProvider> _loadWebImage(String path) async => networkImage(path);

Future<pw.ImageProvider> _loadImageFromAssets(String path) async =>
    await imageFromAssetBundle(path);

Future<pw.ImageProvider> _loadImageFromFile(String path) async {
  Uint8List x = File(path).readAsBytesSync();
  return pw.MemoryImage(x);
}

// Summary rows helper
List<pw.TableRow> summaryRows(PackingList list) {
  return [
    smallLabelFatValueRow("Container no:", "${list.containerNo}"),
    smallRow("Type container:", list.containerType),
    blankRow(),
    smallRow("Name:", list.containerName),
    smallRow("Description:", list.containerDescription),
    blankRow(),
    smallLabelFatValueRow(
      "Weight:",
      "${list.totalWeight.toStringAsFixed(2)} kg",
    ),
    blankRow(),
  ];
}

// Dangerous goods
Future<List<pw.Widget>> dangerousGoodsLabels(
  List<PackingDangerousGood> goods,
) async {
  return dangerousGoods(
    goods,
    (ws) => pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ws,
    ),
  );
}

Future<List<pw.Widget>> dangerousGoodsPackingList(
  List<PackingDangerousGood> goods,
) async {
  return dangerousGoods(
    goods,
    (ws) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: ws,
    ),
  );
}

Future<List<pw.Widget>> dangerousGoods(
  List<PackingDangerousGood> goods,
  pw.Widget Function(List<pw.Widget> ws) fn,
) async {
  if (goods.isEmpty) {
    return [];  // Return empty list - no labels needed for no dangerous goods
  }
  var futures = goods.map((good) => _perGood(good, fn));
  return Future.wait(futures);
}

Future<pw.Widget> _perGood(
  PackingDangerousGood good,
  pw.Widget Function(List<pw.Widget> ws) renderFn,
) async {
  var g = await _dangerousGood(good);
  return pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    padding: const pw.EdgeInsets.all(4.0),
    child: renderFn(g),
  );
}

Future<List<pw.Widget>> _dangerousGood(PackingDangerousGood good) async => [
  _dangerousGoodsTable(good),
  await loadImage(good.imagePath, 80, 80),
];

pw.Widget _dangerousGoodsTable(PackingDangerousGood good) => pw.Table(
  children: [
    smallLabelFatValueRow("Dangerous goods:", "Yes"),
    smallRow("Type:", good.dangerType),
    smallRow("IATA ID:", good.iataId),
    smallRow("Proper shipping name:", good.properShippingName),
    smallRow("Max weight PAX:", "${good.maxWeightPAX.toStringAsFixed(1)} kg"),
    smallRow(
      "Max weight Cargo:",
      "${good.maxWeightCargo.toStringAsFixed(1)} kg",
    ),
    smallRow("Remarks:", good.remarks),
  ],
);
