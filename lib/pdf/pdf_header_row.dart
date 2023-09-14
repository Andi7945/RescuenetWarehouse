import 'package:pdf/widgets.dart' as pw;

import 'package:intl/intl.dart';

import 'pdf_utils.dart';

Future<pw.Widget> headerRow(pw.Widget leftCorner,
    [pw.Widget? rightSide]) async {
  return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8.0),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: leftCorner, flex: 5),
        pw.SizedBox(width: 8),
        pw.Expanded(child: await rightSideHeader(rightSide), flex: 5)
      ]));
}

Future<pw.Widget> rightSideHeader(pw.Widget? rightSide,
    [pw.Widget? companyInfoAppendix]) async {
  return pw.Container(
      width: double.infinity,
      child: pw.Column(children: [
        _logoAndCompanyInformation(await _logo(), companyInfoAppendix),
        pw.SizedBox(height: 8),
        rightSide ?? pw.Container()
      ]));
}

_logoAndCompanyInformation(pw.Widget logo, pw.Widget? companyInfoAppendix) =>
    pw.Row(children: [
      pw.Expanded(
          child: pw.Padding(
              padding: const pw.EdgeInsets.only(right: 8.0),
              child: _exec(companyInfoAppendix)),
          flex: 2),
      pw.Expanded(child: logo, flex: 3)
    ]);

Future<pw.Widget> _logo() async => loadImage('rn_logo_big.png');

pw.Container _exec(pw.Widget? companyInfoAppendix) => pw.Container(
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
          companyInfoAppendix ?? empty,
        ]));

String _now() {
  final DateFormat formatter = DateFormat.yMMMd('en_US').add_Hm();
  return formatter.format(DateTime.now());
}
