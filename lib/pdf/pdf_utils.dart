import 'package:pdf/widgets.dart' as pw;

smallText(String text) =>
    pw.Text(text, style: const pw.TextStyle(fontSize: 10.0));

var empty = pw.SizedBox(height: 10);

tableHeadline(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(2.0),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 10.0, fontWeight: pw.FontWeight.bold)));

tableCell(String text) =>
    pw.Padding(padding: const pw.EdgeInsets.all(2.0), child: smallText(text));
