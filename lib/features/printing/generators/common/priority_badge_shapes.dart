import 'package:pdf/pdf.dart';

/// Pure function for drawing the priority badge background using vector paths.

/// Draws a rectangle shape with rounded corners.
///
/// Note this finishes with `fillPath()` rather than `fillAndStrokePath()`, so
/// the stroke colour set below is never rendered and the rectangle has no
/// visible border. That is intentional.
void drawRectangle(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    ..moveTo(4, 2)
    ..lineTo(size.x - 4, 2)
    ..curveTo(size.x - 2, 2, size.x - 2, 2, size.x - 2, 4)
    ..lineTo(size.x - 2, size.y - 4)
    ..curveTo(
      size.x - 2,
      size.y - 2,
      size.x - 2,
      size.y - 2,
      size.x - 4,
      size.y - 2,
    )
    ..lineTo(4, size.y - 2)
    ..curveTo(2, size.y - 2, 2, size.y - 2, 2, size.y - 4)
    ..lineTo(2, 4)
    ..curveTo(2, 2, 2, 2, 4, 2)
    ..closePath()
    ..fillPath();
}
