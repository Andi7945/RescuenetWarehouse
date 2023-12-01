import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/auth_util.dart';

import 'packing_list.dart';
import 'pdf_header_row.dart';
import 'pdf_utils.dart';

Future<pw.Document> createLabelPdf(PackingList list) async {
  var goods = await dangerousGoodsLabels(list.dangerousGoods);
  var totalPages =
      (goods.length / 2).floor() + 1; // one on first page, two on others

  final pdf = pw.Document();
  var page = _labelPage(await firstPage(list, goods.first, 1, totalPages));
  pdf.addPage(page);

  var additional = goods.skip(1).toList();
  for (var i = 0; i < additional.length; i += 2) {
    var left = additional[i];
    var right =
        additional.length > (i + 1) ? additional[i + 1] : pw.Container();
    var p = _labelPage(await otherPages(
        left, right, (i / 2).floor() + 2, totalPages, list.containerNo));
    pdf.addPage(p);
  }

  return pdf;
}

_labelPage(pw.Widget w) => pw.Page(
      pageFormat: pageFormatLabels,
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) => w,
    );

Future<pw.Column> firstPage(PackingList list, pw.Widget good, int currentPage,
    int numberOfPages) async {
  var top = await rightSideHeader(
      null, smallText("Label $currentPage / $numberOfPages"));
  return pw.Column(children: [
    top,
    pw.SizedBox(height: 8),
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: _left(list)),
      pw.SizedBox(width: 16),
      pw.Expanded(child: good)
    ])
  ]);
}

_left(PackingList list) =>
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      summaryTable(summaryRows(list)),
      pw.Row(children: [
        valueBox("Destination:", list.destination),
        valueBox("Seq. build prio:", list.sequentialBuild.displayName, 0.0,
            PdfColor.fromInt(list.sequentialBuild.color.value))
      ])
    ]);

Future<pw.Column> otherPages(pw.Widget good, pw.Widget? good2, int currentPage,
    int numberOfPages, int containerNo) async {
  var top = await _headerPage2(
      smallText("Label $currentPage / $numberOfPages"), containerNo);
  return pw.Column(children: [
    top,
    pw.SizedBox(height: 8),
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: good),
      pw.SizedBox(width: 16),
      pw.Expanded(child: good2 ?? pw.Container())
    ])
  ]);
}

_headerPage2(pw.Widget? companyInfoAppendix, int containerNo) =>
    pw.Row(children: [
      pw.Expanded(
          child: pw.Padding(
              padding: const pw.EdgeInsets.only(right: 8.0),
              child: _exec(companyInfoAppendix)),
          flex: 2),
      pw.Expanded(
          child: _boxPage2(pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                smallText("Container no:"),
                pw.SizedBox(width: 16),
                biggerAndFat("$containerNo")
              ])),
          flex: 2)
    ]);

_boxPage2(pw.Widget w) => pw.Container(
    padding: const pw.EdgeInsets.all(4.0),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: w);

pw.Container _exec(pw.Widget? companyInfoAppendix) => _boxPage2(pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          smallText("Printed by: ${Auth().currentUserName}"),
          smallText("Date: ${_now()}"),
          companyInfoAppendix ?? empty,
        ]));

String _now() {
  final DateFormat formatter = DateFormat.yMMMd('en_US').add_Hm();
  return formatter.format(DateTime.now());
}
