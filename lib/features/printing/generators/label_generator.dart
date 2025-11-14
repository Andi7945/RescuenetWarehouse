import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/label_format.dart';
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

import 'common/pdf_base_widgets.dart';
import 'common/priority_badge_widget.dart';

/// Coordinate scaling configuration for label layout
///
/// User-specified coordinates are defined on a 1150×1700 canvas (portrait).
/// We scale these to fit A6 landscape (420pt × 298pt) with X/Y swapped.
/// Source X (0-1150) maps to target Y (0-298)
/// Source Y (0-1700) maps to target X (0-420)
class _LabelCoordinates {
  // Source canvas dimensions (user specification in portrait)
  static const double sourceWidth = 1150.0;
  static const double sourceHeight = 1700.0;

  // Target page dimensions (A6 landscape in points)
  static const double targetWidth = 420.0;
  static const double targetHeight = 298.0;

  // Scaling factors (swapped because coordinates are inverted)
  static const double scaleX = targetHeight / sourceWidth;  // ≈ 0.259
  static const double scaleY = targetWidth / sourceHeight;  // ≈ 0.247

  /// Scales X coordinate from source to target (maps to Y axis)
  static double x(double sourceX) => sourceX * scaleX;

  /// Scales Y coordinate from source to target (maps to X axis)
  static double y(double sourceY) => sourceY * scaleY;

  /// Scales width from source to target (maps to height)
  static double w(double sourceWidth) => sourceWidth * scaleX;

  /// Scales height from source to target (maps to width)
  static double h(double sourceHeight) => sourceHeight * scaleY;
}

/// Box dimensions and positions (source coordinates)
class _BoxSpec {
  final double x;
  final double y;
  final double width;
  final double height;
  final bool hasBorder;

  const _BoxSpec({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.hasBorder,
  });

  // Box specifications from user requirements
  static const box1 = _BoxSpec(x: 50, y: 50, width: 240, height: 900, hasBorder: true);
  static const box2 = _BoxSpec(x: 50, y: 1000, width: 240, height: 700, hasBorder: false);
  static const box3 = _BoxSpec(x: 340, y: 50, width: 500, height: 900, hasBorder: true);
  static const box4 = _BoxSpec(x: 340, y: 1200, width: 500, height: 500, hasBorder: false);
  static const box5 = _BoxSpec(x: 880, y: 50, width: 220, height: 1075, hasBorder: true);
  static const box6 = _BoxSpec(x: 880, y: 1160, width: 220, height: 520, hasBorder: true);
}

/// Generate container label PDF document from multiple packing lists
///
/// For each container in [packingLists], generates label widgets (one per container)
/// and arranges them into physical pages based on [format]:
/// - A6 format: one label per A6 page
/// - A4 2×2 format: four labels per A4 page in a 2×2 grid
Future<pw.Document> generateLabelPdf(
  List<PackingList> packingLists,
  PrintContext context,
  LabelFormat format,
) async {
  final pdf = pw.Document();

  // Build all label widgets from all containers
  final allLabels = <pw.Widget>[];
  for (final packingList in packingLists) {
    final labels = await _buildLabelsForContainer(packingList, context);
    allLabels.addAll(labels);
  }

  // Arrange labels into physical pages based on format
  final pages = _buildPages(allLabels, format);

  for (final page in pages) {
    pdf.addPage(page);
  }

  return pdf;
}

/// Build label widgets for a single container
///
/// Returns a list of label widgets. Labels are rendered in different orientations
/// depending on the output format (A6 landscape or A4 portrait grid).
/// - First label: summary info ONLY (no dangerous goods)
/// - Subsequent labels: two dangerous goods per label
Future<List<pw.Widget>> _buildLabelsForContainer(
  PackingList packingList,
  PrintContext context,
) async {
  final goods = await dangerousGoodsLabels(packingList.dangerousGoods);

  // Calculate total pages: 1 summary + ceiling of (dangerous goods / 2)
  final totalPages = 1 + (goods.length / 2).ceil();
  final labels = <pw.Widget>[];

  // First label: summary info only (no dangerous goods)
  final firstLabel = await _buildFirstLabel(
    packingList,
    1,
    totalPages,
    context,
  );
  labels.add(firstLabel);

  // All dangerous goods on subsequent labels: two per label
  for (var i = 0; i < goods.length; i += 2) {
    final left = goods[i];
    final right = goods.length > (i + 1)
        ? goods[i + 1]
        : pw.Container();

    final label = await _buildSubsequentLabel(
      left,
      right,
      (i / 2).floor() + 2,
      totalPages,
      packingList.containerNo,
      context,
    );
    labels.add(label);
  }

  return labels;
}

/// Arrange label widgets into physical pages based on format
///
/// Pure function that takes a flat list of label widgets and arranges them
/// into PDF pages according to the specified format:
/// - A6 format: one label per A6 page
/// - A4 2×2 format: each label printed 5 times, four labels per A4 page in a 2×2 grid
List<pw.Page> _buildPages(List<pw.Widget> labels, LabelFormat format) {
  final pages = <pw.Page>[];

  if (format == LabelFormat.a6) {
    // A6 format: one label per page
    for (final label in labels) {
      pages.add(_labelPageA6(label));
    }
  } else {
    // A4 2×2 format: duplicate each label 5 times before arranging
    final expandedLabels = <pw.Widget>[];
    for (final label in labels) {
      for (var i = 0; i < 5; i++) {
        expandedLabels.add(label);
      }
    }

    // Four labels per page in a grid
    for (var i = 0; i < expandedLabels.length; i += 4) {
      final topLeft = expandedLabels[i];
      final topRight = i + 1 < expandedLabels.length ? expandedLabels[i + 1] : null;
      final bottomLeft = i + 2 < expandedLabels.length ? expandedLabels[i + 2] : null;
      final bottomRight = i + 3 < expandedLabels.length ? expandedLabels[i + 3] : null;

      pages.add(_labelPageA4Grid(topLeft, topRight, bottomLeft, bottomRight));
    }
  }

  return pages;
}

/// Create a physical A4 page with 2×2 grid of labels
///
/// A4 is 21.0 × 29.7 cm, each A6 portrait label is 10.5 × 14.8 cm
/// Grid layout: 2 × 10.5 = 21.0 cm (width), 2 × 14.8 = 29.6 cm (height) - perfect fit
/// Zero margins are critical for exact fit
pw.Page _labelPageA4Grid(
  pw.Widget topLeft,
  pw.Widget? topRight,
  pw.Widget? bottomLeft,
  pw.Widget? bottomRight,
) {
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (pw.Context context) => pw.Column(
      children: [
        // Top row
        pw.Row(
          children: [
            _withMeasurementsPortrait(topLeft),
            _withMeasurementsPortrait(topRight ?? pw.Container()),
          ],
        ),
        // Bottom row
        pw.Row(
          children: [
            _withMeasurementsPortrait(bottomLeft ?? pw.Container()),
            _withMeasurementsPortrait(bottomRight ?? pw.Container()),
          ],
        ),
      ],
    ),
  );
}

/// Create a physical A6 page with one label
pw.Page _labelPageA6(pw.Widget w) => pw.MultiPage(
  pageFormat: PdfPageFormat.a6.landscape,
  margin: pw.EdgeInsets.zero,
  build: (pw.Context context) => [
    _withMeasurements(w),
  ],
);

/// Wrap label with correct measurements (landscape orientation for A6 format)
pw.Widget _withMeasurements(pw.Widget label) => pw.Container(
  child: pw.SizedBox(width: 14.8 * cm, height: 10.5 * cm, child: label),
);

/// Wrap label with portrait measurements (for A4 2×2 grid)
/// Rotates the landscape label 90 degrees clockwise to fit portrait orientation
pw.Widget _withMeasurementsPortrait(pw.Widget label) {
  // Labels are built in landscape (14.8 × 10.5 cm)
  // For A4 2×2 grid, we need portrait (10.5 × 14.8 cm)
  // Rotate 90 degrees clockwise (π/2 radians)
  return pw.Container(
    width: 10.5 * cm,
    height: 14.8 * cm,
    child: pw.Center(
      child: pw.Transform.rotate(
        angle: math.pi / 2, // 90 degrees clockwise
        child: pw.SizedBox(
          width: 14.8 * cm,
          height: 10.5 * cm,
          child: label,
        ),
      ),
    ),
  );
}

/// Box 1: Contact information and print metadata (top-left, with border)
pw.Widget _buildBox1ContactInfo(PrintContext context) {
  return pw.Container(
    decoration: _BoxSpec.box1.hasBorder
      ? pw.BoxDecoration(border: pw.Border.all(width: 0.5))
      : null,
    padding: const pw.EdgeInsets.all(8),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${context.organizationEmail} / ${context.organizationPhone}',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 4),
        smallText('Printed by: ${context.userName}, ${_formatDate(context.printDate)}'),
      ],
    ),
  );
}

/// Box 2: Organization logo (bottom-left, no border)
pw.Widget _buildBox2Logo(pw.ImageProvider logo) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Center(
      child: pw.Image(
        logo,
        height: _LabelCoordinates.h(500), // Scale logo proportionally
        fit: pw.BoxFit.contain,
      ),
    ),
  );
}

/// Box 3: Container number (top-center, with border)
pw.Widget _buildBox3ContainerNumber(PackingList list) {
  return pw.Container(
    decoration: _BoxSpec.box3.hasBorder
      ? pw.BoxDecoration(border: pw.Border.all(width: 0.5))
      : null,
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

/// Box 4: Priority badge (bottom-center, no border)
pw.Widget _buildBox4PriorityBadge(PackingList list) {
  // Always show badge - buildPriorityBadge handles the rendering
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Center(
      child: buildPriorityBadge(
        priority: list.priority,
        destination: list.destination,
        widthCm: _LabelCoordinates.w(450) / cm,  // Convert points to cm
        heightCm: _LabelCoordinates.h(450) / cm, // Convert points to cm
      ),
    ),
  );
}

/// Box 5: Container details (top-right, with border)
pw.Widget _buildBox5Details(PackingList list) {
  return pw.Container(
    decoration: _BoxSpec.box5.hasBorder
      ? pw.BoxDecoration(border: pw.Border.all(width: 0.5))
      : null,
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

/// Box 6: Weight display with icon (bottom-right, with border)
pw.Widget _buildBox6Weight(PackingList list, pw.ImageProvider weightIcon) {
  return pw.Container(
    decoration: _BoxSpec.box6.hasBorder
      ? pw.BoxDecoration(border: pw.Border.all(width: 0.5))
      : null,
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

/// Builds the first label page with 6-box absolute positioning layout
Future<pw.Widget> _buildFirstLabel(
  PackingList list,
  int currentPage,
  int numberOfPages,
  PrintContext context,
) async {
  final logo = await _loadLogo(context.logoAssetPath);
  final weightIcon = await _loadLogo('assets/images/label_kg.png');

  return pw.Stack(
    children: [
      // Box 1: Contact info (top-left, with border)
      pw.Positioned(
        left: _LabelCoordinates.y(_BoxSpec.box1.y),
        top: _LabelCoordinates.x(_BoxSpec.box1.x),
        child: pw.SizedBox(
          width: _LabelCoordinates.h(_BoxSpec.box1.height),
          height: _LabelCoordinates.w(_BoxSpec.box1.width),
          child: _buildBox1ContactInfo(context),
        ),
      ),

      // Box 2: Logo (bottom-left, no border)
      pw.Positioned(
        left: _LabelCoordinates.y(_BoxSpec.box2.y),
        top: _LabelCoordinates.x(_BoxSpec.box2.x),
        child: pw.SizedBox(
          width: _LabelCoordinates.h(_BoxSpec.box2.height),
          height: _LabelCoordinates.w(_BoxSpec.box2.width),
          child: _buildBox2Logo(logo),
        ),
      ),

      // Box 3: Container number (top-center, with border)
      pw.Positioned(
        left: _LabelCoordinates.y(_BoxSpec.box3.y),
        top: _LabelCoordinates.x(_BoxSpec.box3.x),
        child: pw.SizedBox(
          width: _LabelCoordinates.h(_BoxSpec.box3.height),
          height: _LabelCoordinates.w(_BoxSpec.box3.width),
          child: _buildBox3ContainerNumber(list),
        ),
      ),

      // Box 4: Priority badge (bottom-center, no border)
      pw.Positioned(
        left: _LabelCoordinates.y(_BoxSpec.box4.y),
        top: _LabelCoordinates.x(_BoxSpec.box4.x),
        child: pw.SizedBox(
          width: _LabelCoordinates.h(_BoxSpec.box4.height),
          height: _LabelCoordinates.w(_BoxSpec.box4.width),
          child: _buildBox4PriorityBadge(list),
        ),
      ),

      // Box 5: Details (top-right, with border)
      pw.Positioned(
        left: _LabelCoordinates.y(_BoxSpec.box5.y),
        top: _LabelCoordinates.x(_BoxSpec.box5.x),
        child: pw.SizedBox(
          width: _LabelCoordinates.h(_BoxSpec.box5.height),
          height: _LabelCoordinates.w(_BoxSpec.box5.width),
          child: _buildBox5Details(list),
        ),
      ),

      // Box 6: Weight (bottom-right, with border)
      pw.Positioned(
        left: _LabelCoordinates.y(_BoxSpec.box6.y),
        top: _LabelCoordinates.x(_BoxSpec.box6.x),
        child: pw.SizedBox(
          width: _LabelCoordinates.h(_BoxSpec.box6.height),
          height: _LabelCoordinates.w(_BoxSpec.box6.width),
          child: _buildBox6Weight(list, weightIcon),
        ),
      ),
    ],
  );
}

/// Load logo from assets
Future<pw.ImageProvider> _loadLogo(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  return pw.MemoryImage(data.buffer.asUint8List());
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

/// Build subsequent labels (pages 2+)
Future<pw.Column> _buildSubsequentLabel(
  pw.Widget good,
  pw.Widget? good2,
  int currentPage,
  int numberOfPages,
  int containerNo,
  PrintContext context,
) async {
  final top = await _buildHeaderForSubsequentLabel(
    currentPage,
    numberOfPages,
    containerNo,
    context,
  );
  return pw.Column(
    children: [
      top,
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: good),
          pw.SizedBox(width: 16),
          pw.Expanded(child: good2 ?? pw.Container()),
        ],
      ),
    ],
  );
}

/// Build header for subsequent labels
Future<pw.Widget> _buildHeaderForSubsequentLabel(
  int currentPage,
  int numberOfPages,
  int containerNo,
  PrintContext context,
) async {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(right: 8.0),
          child: _buildInfoBox(context),
        ),
        flex: 2,
      ),
      pw.Expanded(
        child: _buildBox(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  smallText("Label $currentPage / $numberOfPages"),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      smallText("Container no:"),
                      pw.SizedBox(width: 16),
                      biggerAndFat("$containerNo"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        flex: 2,
      ),
    ],
  );
}

/// Build info box with user and org context
pw.Widget _buildInfoBox(PrintContext context) {
  return _buildBox(
    pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        smallText("Printed by: ${context.userName}, ${_formatDate(context.printDate)}"),
      ],
    ),
  );
}

/// Build a bordered box
pw.Widget _buildBox(pw.Widget w) => pw.Container(
  padding: const pw.EdgeInsets.all(4.0),
  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
  child: w,
);

/// Formats date with ordinal day (e.g., "April 19th 2023")
String _formatDate(DateTime date) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final ordinal = _getOrdinalSuffix(date.day);
  return '${months[date.month - 1]} ${date.day}$ordinal ${date.year}';
}

/// Returns ordinal suffix for a day number (st, nd, rd, th)
String _getOrdinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th'; // Special case: 11th, 12th, 13th
  }

  switch (day % 10) {
    case 1:
      return 'st'; // 1st, 21st, 31st
    case 2:
      return 'nd'; // 2nd, 22nd
    case 3:
      return 'rd'; // 3rd, 23rd
    default:
      return 'th'; // 4th-10th, 14th-20th, 24th-30th
  }
}
