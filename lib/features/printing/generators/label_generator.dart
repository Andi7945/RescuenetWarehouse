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

/// Build the first label with new 3-row layout
///
/// Row 1: Contact info (60%) + Logo (40%)
/// Row 2: Huge container number (60%) + Destination (40%)
/// Row 3: Details (70%) + Weight (30%)
Future<pw.Column> _buildFirstLabel(
  PackingList list,
  int currentPage,
  int numberOfPages,
  PrintContext context,
) async {
  final logo = await _loadLogo(context.logoAssetPath);

  return pw.Column(
    children: [
      // Row 1: Contact info + Logo
      await _buildTopRow(context, logo, currentPage, numberOfPages),
      pw.SizedBox(height: 8),

      // Row 2: Huge container number + Destination
      _buildMiddleRow(list),
      pw.SizedBox(height: 8),

      // Row 3: Details + Weight
      _buildBottomRow(list),
    ],
  );
}

/// Load logo from assets
Future<pw.ImageProvider> _loadLogo(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  return pw.MemoryImage(data.buffer.asUint8List());
}

/// Build top row: Contact info (60%) + Logo (40%)
Future<pw.Widget> _buildTopRow(
  PrintContext context,
  pw.ImageProvider logo,
  int currentPage,
  int totalPages,
) async {
  return pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Row(
      children: [
        // Left 60%: Contact info + Print metadata
        pw.Expanded(
          flex: 60,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(6.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                _buildInfoLine('Email', context.organizationEmail),
                pw.SizedBox(height: 4),
                _buildInfoLine('Phone', context.organizationPhone),
                pw.SizedBox(height: 8),
                smallText('Printed by: ${context.userName}'),
                pw.SizedBox(height: 2),
                smallText('Date: ${_formatDate(context.printDate)}'),
              ],
            ),
          ),
        ),

        // Right 40%: Logo + Page indicator
        pw.Expanded(
          flex: 40,
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Image(logo, height: 60),
              ),
              _buildPageIndicator(currentPage, totalPages),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Build middle row: Huge container number (60%) + Destination (40%)
pw.Widget _buildMiddleRow(PackingList list) {
  return pw.Container(
    height: 80, // Double height row
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Row(
      children: [
        // Left 60%: HUGE container number
        pw.Expanded(
          flex: 60,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  '#:',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  '${list.containerNo}',
                  style: pw.TextStyle(
                    fontSize: 48,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right 40%: Priority badge
        pw.Expanded(
          flex: 40,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            decoration: pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(width: 0.5)),
            ),
            child: buildPriorityBadge(
              priority: list.priority,
              destination: list.destination,
              widthCm: 3.5,
              heightCm: 3.0,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Build bottom row: Details (70%) + Weight (30%)
pw.Widget _buildBottomRow(PackingList list) {
  return pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Row(
      children: [
        // Left 70%: Name, Description, Type
        pw.Expanded(
          flex: 70,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(6.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                _buildInfoLine('Name', list.containerName),
                pw.SizedBox(height: 4),
                _buildInfoLine('Description', list.containerDescription),
                pw.SizedBox(height: 4),
                _buildInfoLine('Type', list.containerType),
              ],
            ),
          ),
        ),

        // Right 30%: Weight
        pw.Expanded(
          flex: 30,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            decoration: pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(width: 0.5)),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Weight',
                  style: pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${list.totalWeight.round()} kg',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
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

/// Build page indicator
pw.Widget _buildPageIndicator(int current, int total) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(width: 0.5)),
    ),
    child: pw.Center(
      child: smallText('Label $current / $total'),
    ),
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
        smallText("Printed by: ${context.userName}"),
        smallText("Date: ${_formatDate(context.printDate)}"),
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

/// Formats date in readable format (e.g., "November 14, 2025")
String _formatDate(DateTime date) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
