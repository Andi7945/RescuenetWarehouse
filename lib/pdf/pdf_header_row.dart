import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:intl/intl.dart';

import 'pdf_utils.dart';

headerRow(pw.Widget leftCorner) async {
  var logo = await _logo();
  return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Expanded(child: leftCorner, flex: 5),
    pw.Expanded(
        child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
            child: _exec()),
        flex: 2),
    pw.Expanded(child: logo, flex: 3)
  ]);
}

_logo() async {
  final img = await rootBundle.load('assets/images/LogoRN.png');
  final imageBytes = img.buffer.asUint8List();
  pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));
  return image1;
}

_exec() => pw.Container(
    padding: const pw.EdgeInsets.all(4.0),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          smallText("backoffice@rescuenet.net"),
          smallText("+31-6-14419988"),
          empty,
          smallText("Printed by: GJP"),
          smallText("Date: ${_now()}"),
          empty,
        ]));

String _now() {
  final DateFormat formatter = DateFormat.yMMMMd('en_US');
  return formatter.format(DateTime.now());
}
