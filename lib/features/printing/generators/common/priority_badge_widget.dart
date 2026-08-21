import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/generators/common/pdf_base_widgets.dart';
import 'package:rescuenet_warehouse/features/printing/generators/common/priority_badge_shapes.dart';
import 'package:rescuenet_warehouse/pdf/print_sorting.dart';

/// Builds a priority badge widget for container labels.
///
/// This is a pure function that creates a PDF widget displaying:
/// - A coloured rectangle, filled according to [priority] alone
/// - Priority number ("Prio 1", "Prio 2", etc.)
/// - Destination name
///
/// The colour is keyed on the priority only - see [_getPriorityColor].
pw.Widget buildPriorityBadge({
  required int priority,
  required String destination,
  required double widthCm,
  required double heightCm,
}) {
  // Get background color based on priority
  final backgroundColor = _getPriorityColor(priority);

  return pw.Container(
    width: widthCm * cm,
    height: heightCm * cm,
    child: pw.Stack(
      children: [
        // Background rectangle
        pw.CustomPaint(
          size: PdfPoint(widthCm * cm, heightCm * cm),
          painter: (canvas, size) {
            drawRectangle(canvas, size, backgroundColor);
          },
        ),
        // Text overlay
        pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // Priority number (bold, larger)
              pw.Text(
                'Prio $priority',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 4),
              // Destination name (regular, smaller)
              pw.Container(
                width: widthCm * cm * 0.8, // 80% width for text wrapping
                child: pw.Text(
                  destination,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                  maxLines: 3,
                  overflow: pw.TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Returns the background color for a priority level.
///
/// 1 red, 2 yellow, 3 green, 4 blue.
/// [unprioritisedRank] renders uncoloured (white fill) so a destination
/// without a configured priority is visibly unconfigured on the label.
PdfColor _getPriorityColor(int priority) {
  switch (priority) {
    case unprioritisedRank:
      return PdfColors.white;
    case 1:
      return PdfColors.red;
    case 2:
      return PdfColors.yellow;
    case 3:
      return PdfColors.green;
    case 4:
      return PdfColors.blue;
    default:
      return PdfColors.red; // Safe fallback
  }
}
