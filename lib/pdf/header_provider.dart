import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'packing_list.dart';
import 'package:intl/intl.dart';

import 'pdf_header_row.dart';
import 'pdf_utils.dart';

/*
 * For the packing list we want one pdf but start the page counter for each one separately.
 * So we create a provider per new document and save what index is the first one.
 */
class HeaderProvider {
  int smallestPage = 0;

  Future<pw.Widget Function(int)> provideHeader(PackingList list) async {
    var big = await _header(list);
    var small = await _headerSmall(list);
    return (int i) => isFirstPage(i) ? big : small;
  }

  bool isFirstPage(int i) {
    if (smallestPage == 0) {
      smallestPage = i;
      return true;
    }
    return i == smallestPage;
  }

  Future<pw.Widget> _header(PackingList list) async {
    var upperLeft = _upperLeft(list);
    var rightChild = await dangerousGoodsPackingList(list.dangerousGoods);
    var top = await headerRow(upperLeft, rightChild.first);
    var additionalGoods = rightChild.skip(1).toList();

    var grid = _grid(additionalGoods);

    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8.0),
        child: pw.Column(children: [top, grid]));
  }

  pw.Widget _grid(List<pw.Widget> goods) {
    List<pw.Widget> rows = [];
    for (var i = 0; i < goods.length; i += 2) {
      rows.add(_buildGridRow(goods, i));
      rows.add(pw.SizedBox(height: 8));
    }
    return pw.Column(children: rows);
  }

  pw.Widget _buildGridRow(List<pw.Widget> goods, int idx) {
    var left = pw.Flexible(child: goods[idx]);
    var right = goods.length > (idx + 1)
        ? pw.Flexible(child: goods[idx + 1])
        : pw.Flexible(child: pw.Container());
    return pw.Row(children: [left, pw.SizedBox(width: 8), right]);
  }

  Future<pw.Widget> _headerSmall(PackingList list) async {
    return await headerRow(_smallUpperLeft(list));
  }

  _upperLeft(PackingList list) {
    DateFormat formatter = DateFormat("MMMM '' yy");
    return pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
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

  _smallUpperLeft(PackingList list) => summaryTable([
        pw.TableRow(children: [bigger("Packing list"), pw.Container()]),
        smallLabelFatValueRow("Container no:", "${list.containerNo}")
      ]);

  _summaryRows(PackingList list) => [
        pw.TableRow(children: [bigger("Packing list"), pw.Container()]),
        ...summaryRows(list)
      ];
}
