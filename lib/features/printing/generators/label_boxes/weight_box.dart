import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

/// Box 6: Weight display with icon (bottom-right, with border)
class WeightBox {
  final PackingList list;
  final pw.ImageProvider weightIcon;

  const WeightBox({
    required this.list,
    required this.weightIcon,
  });

  pw.Widget build() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Weight icon
            pw.Image(
              weightIcon,
              width: 40,
              height: 40,
              fit: pw.BoxFit.contain,
            ),
            pw.SizedBox(height: 6),
            // Weight value
            pw.Text(
              '${list.totalWeight.round()}',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
