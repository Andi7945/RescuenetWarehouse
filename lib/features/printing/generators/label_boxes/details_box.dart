import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

/// Box 5: Container details (top-right, with border)
class DetailsBox {
  final PackingList list;

  const DetailsBox({required this.list});

  pw.Widget build() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoLine('Name', list.containerName),
          pw.SizedBox(height: 4),
          _buildInfoLine('Description', list.containerDescription),
          pw.SizedBox(height: 4),
          _buildInfoLine('Type', list.containerType),
        ],
      ),
    );
  }

  /// Build an info line with label and value
  pw.Widget _buildInfoLine(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label: ',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
