import 'package:pdf/widgets.dart' as pw;

import 'packing_list.dart';
import 'pdf_header_row.dart';
import 'pdf_utils.dart';

Future<pw.Document> createLabelPdf(List<PackingList> lists) async {
  final pdf = pw.Document();
  var pages = lists.map((e) async => _labelPage(await _body(e)));
  var builded = await Future.wait(pages);
  for (var page in builded) {
    pdf.addPage(page);
  }
  return pdf;
}

_labelPage(pw.Widget w) => pw.Page(
      pageFormat: pageFormatLabels,
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) => w,
    );

Future<pw.Column> _body(PackingList list) async {
  var top = await rightSideHeader(null);
  var right = await dangerousGoodsLabels(list.dangerousGoods);
  return pw.Column(children: [
    top,
    pw.SizedBox(height: 8),
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: _left(list)),
      pw.SizedBox(width: 16),
      pw.Expanded(child: right)
    ])
    // pw.Row(children: [right])
  ]);
}

_left(PackingList list) =>
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      summaryTable(summaryRows(list)),
      pw.Row(children: [
        valueBox("Destination:", list.destination),
        valueBox("Seq. build prio:", list.sequentialBuildPrio, 0.0)
      ])
    ]);
