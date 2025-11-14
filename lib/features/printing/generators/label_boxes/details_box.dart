import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

/// Box 5: Container details (top-right, with border)
class DetailsBox {
  final PackingList list;

  const DetailsBox({required this.list});

  pw.Widget build() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildTableRow('Name', list.containerName, isName: true),
          pw.SizedBox(height: 4),
          _buildTableRow('Description', list.containerDescription),
          pw.SizedBox(height: 4),
          _buildTableRow('Type', list.containerType),
        ],
      ),
    );
  }

  /// Build a table-like row with aligned label and value columns
  pw.Widget _buildTableRow(String label, String value, {bool isName = false}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Fixed-width label column for alignment
        pw.SizedBox(
          width: 70, // Enough width for "Description:"
          child: pw.Text(
            '$label:',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        // Flexible value column
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isName ? 14 : 9, // Name is larger (14pt)
              fontWeight: isName ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
