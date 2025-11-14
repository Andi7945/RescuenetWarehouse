import 'package:pdf/pdf.dart';

/// Pure functions for drawing priority badge shapes using vector paths.
/// These match the exact paths from the SVG assets in assets/priority_badges/.

/// Draws a circle shape (Priority 1)
void drawCircle(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  final center = PdfPoint(size.x / 2, size.y / 2);
  final radius = (size.x < size.y ? size.x : size.y) / 2 - 2;

  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    ..drawEllipse(center.x, center.y, radius, radius)
    ..fillPath();
}

/// Draws a rectangle shape with rounded corners (Priority 1)
void drawRectangle(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    ..moveTo(4, 2)
    ..lineTo(size.x - 4, 2)
    ..curveTo(size.x - 2, 2, size.x - 2, 2, size.x - 2, 4)
    ..lineTo(size.x - 2, size.y - 4)
    ..curveTo(size.x - 2, size.y - 2, size.x - 2, size.y - 2, size.x - 4, size.y - 2)
    ..lineTo(4, size.y - 2)
    ..curveTo(2, size.y - 2, 2, size.y - 2, 2, size.y - 4)
    ..lineTo(2, 4)
    ..curveTo(2, 2, 2, 2, 4, 2)
    ..closePath()
    ..fillPath();
}

/// Draws a triangle shape (Priority 2)
void drawTriangle(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    ..moveTo(size.x / 2, 5) // Top point
    ..lineTo(size.x - 5, size.y - 5) // Bottom right
    ..lineTo(5, size.y - 5) // Bottom left
    ..closePath()
    ..fillPath();
}

/// Draws a diamond shape (Priority 2)
void drawDiamond(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    ..moveTo(size.x / 2, 5) // Top
    ..lineTo(size.x - 5, size.y / 2) // Right
    ..lineTo(size.x / 2, size.y - 5) // Bottom
    ..lineTo(5, size.y / 2) // Left
    ..closePath()
    ..fillPath();
}

/// Draws a 5-point star shape (Priority 3)
void drawStar(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  final cx = size.x / 2;
  final cy = size.y / 2;
  final outerRadius = (size.x < size.y ? size.x : size.y) / 2 - 5;
  final innerRadius = outerRadius * 0.4;

  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2);

  for (int i = 0; i < 10; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = (i * 36 - 90) * 3.14159 / 180; // Convert to radians, start at top
    final x = cx + radius * cos(angle);
    final y = cy + radius * sin(angle);

    if (i == 0) {
      canvas.moveTo(x, y);
    } else {
      canvas.lineTo(x, y);
    }
  }

  canvas
    ..closePath()
    ..fillPath();
}

/// Draws a heart shape (Priority 4)
void drawHeart(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  final cx = size.x / 2;
  final scale = (size.x < size.y ? size.x : size.y) / 100;

  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    ..moveTo(cx, 85 * scale) // Bottom point
    ..curveTo(
      10 * scale, 60 * scale,
      10 * scale, 35 * scale,
      10 * scale, 35 * scale,
    )
    ..curveTo(
      10 * scale, 20 * scale,
      20 * scale, 10 * scale,
      30 * scale, 10 * scale,
    )
    ..curveTo(
      40 * scale, 10 * scale,
      cx, 20 * scale,
      cx, 30 * scale,
    )
    ..curveTo(
      cx, 20 * scale,
      60 * scale, 10 * scale,
      70 * scale, 10 * scale,
    )
    ..curveTo(
      80 * scale, 10 * scale,
      90 * scale, 20 * scale,
      90 * scale, 35 * scale,
    )
    ..curveTo(
      90 * scale, 35 * scale,
      90 * scale, 60 * scale,
      cx, 85 * scale,
    )
    ..closePath()
    ..fillPath();
}

/// Draws a medical cross shape (Priority 4)
void drawCross(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  final armWidth = size.x * 0.3;
  final armHeight = size.y * 0.3;
  final centerX = size.x / 2;
  final centerY = size.y / 2;

  canvas
    ..setFillColor(color)
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(2)
    // Top arm
    ..moveTo(centerX - armWidth / 2, 10)
    ..lineTo(centerX + armWidth / 2, 10)
    ..lineTo(centerX + armWidth / 2, centerY - armHeight / 2)
    // Right arm
    ..lineTo(size.x - 10, centerY - armHeight / 2)
    ..lineTo(size.x - 10, centerY + armHeight / 2)
    ..lineTo(centerX + armWidth / 2, centerY + armHeight / 2)
    // Bottom arm
    ..lineTo(centerX + armWidth / 2, size.y - 10)
    ..lineTo(centerX - armWidth / 2, size.y - 10)
    ..lineTo(centerX - armWidth / 2, centerY + armHeight / 2)
    // Left arm
    ..lineTo(10, centerY + armHeight / 2)
    ..lineTo(10, centerY - armHeight / 2)
    ..lineTo(centerX - armWidth / 2, centerY - armHeight / 2)
    ..closePath()
    ..fillPath();
}

/// Helper function to calculate cosine (approximation)
double cos(double radians) {
  // Taylor series approximation for cosine
  final x = radians;
  return 1 - (x * x) / 2 + (x * x * x * x) / 24 - (x * x * x * x * x * x) / 720;
}

/// Helper function to calculate sine (approximation)
double sin(double radians) {
  // Taylor series approximation for sine
  final x = radians;
  return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
}
