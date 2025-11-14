import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

/// Box 3: Container number (top-center, with border)
class ContainerNumberBox {
  final PackingList list;

  const ContainerNumberBox({required this.list});

  pw.Widget build() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              '#:',
              style: pw.TextStyle(fontSize: 24),
            ),
            pw.SizedBox(width: 16),
            pw.Text(
              '${list.containerNo}',
              style: pw.TextStyle(
                fontSize: 96,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
