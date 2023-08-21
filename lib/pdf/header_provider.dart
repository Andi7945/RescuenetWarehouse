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
    return await headerRow(upperLeft, rightChild);
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
