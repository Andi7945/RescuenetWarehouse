import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/priority_badge_config.dart';
import 'package:rescuenet_warehouse/features/printing/generators/common/pdf_base_widgets.dart';
import 'package:rescuenet_warehouse/features/printing/generators/common/priority_badge_shapes.dart';

/// Builds a priority badge widget for container labels.
///
/// This is a pure function that creates a PDF widget displaying:
/// - Colored shape (circle, triangle, star, heart, diamond, cross, rectangle)
/// - Priority number ("Prio 1", "Prio 2", etc.)
/// - Destination name
///
/// The shape is selected based on the destination name and priority level
/// using the PriorityBadgeConfig mapping.
pw.Widget buildPriorityBadge({
  required int priority,
  required String destination,
  required double widthCm,
  required double heightCm,
}) {
  // Get the appropriate shape for this destination/priority
  final shape = PriorityBadgeConfig.getShapeForDestination(
    destination: destination,
    priority: priority,
  );

  // Get background color based on priority
  final backgroundColor = _getPriorityColor(priority, shape);

  return pw.Container(
    width: widthCm * cm,
    height: heightCm * cm,
    child: pw.Stack(
      children: [
        // Background shape
        pw.CustomPaint(
          size: PdfPoint(widthCm * cm, heightCm * cm),
          painter: (canvas, size) {
            _drawShape(canvas, size, shape, backgroundColor);
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

/// Draws the appropriate shape based on the badge shape enum.
void _drawShape(
  PdfGraphics canvas,
  PdfPoint size,
  PriorityBadgeShape shape,
  PdfColor color,
) {
  switch (shape) {
    case PriorityBadgeShape.circle:
      drawCircle(canvas, size, color);
      break;
    case PriorityBadgeShape.rectangle:
      drawRectangle(canvas, size, color);
      break;
    case PriorityBadgeShape.triangle:
      drawTriangle(canvas, size, color);
      break;
    case PriorityBadgeShape.diamond:
      drawDiamond(canvas, size, color);
      break;
    case PriorityBadgeShape.star:
      drawStar(canvas, size, color);
      break;
    case PriorityBadgeShape.heart:
      drawHeart(canvas, size, color);
      break;
    case PriorityBadgeShape.cross:
      drawCross(canvas, size, color);
      break;
  }
}

/// Returns the background color for a priority level.
/// Note: Priority 4 has different colors for heart vs. cross.
PdfColor _getPriorityColor(int priority, PriorityBadgeShape shape) {
  switch (priority) {
    case 1:
      return PdfColors.red;
    case 2:
      return PdfColors.yellow;
    case 3:
      return PdfColors.green;
    case 4:
      // Different blues for heart vs. cross
      return shape == PriorityBadgeShape.cross
          ? PdfColor.fromHex('#00BFFF') // Light blue for medical cross
          : PdfColors.blue; // Darker blue for heart
    default:
      return PdfColors.red; // Safe fallback
  }
}
