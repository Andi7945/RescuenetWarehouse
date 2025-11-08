import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/label_format.dart';
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

import 'common/pdf_base_widgets.dart';

/// Convert Flutter color int to hex string for PDF
String _colorToHex(int color) {
  return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
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
/// Returns a list of A6-sized label widgets (14.8 × 10.5 cm each).
/// If the container has dangerous goods:
/// - First label: one dangerous good + summary info
/// - Subsequent labels: two dangerous goods per label
/// If no dangerous goods, returns a single label with summary info only.
Future<List<pw.Widget>> _buildLabelsForContainer(
  PackingList packingList,
  PrintContext context,
) async {
  final goods = await dangerousGoodsLabels(packingList.dangerousGoods);

  if (goods.isEmpty) {
    // No dangerous goods: return single label with summary only
    final totalPages = 1;
    final label = await _buildFirstLabel(
      packingList,
      pw.Container(), // No dangerous good to display
      1,
      totalPages,
      context,
    );
    return [label];
  }

  final totalPages = (goods.length / 2).floor() + 1;
  final labels = <pw.Widget>[];

  // First label: one dangerous good plus summary info
  final firstLabel = await _buildFirstLabel(
    packingList,
    goods.first,
    1,
    totalPages,
    context,
  );
  labels.add(firstLabel);

  // Additional labels: two dangerous goods per label
  final remainingGoods = goods.skip(1).toList();
  for (var i = 0; i < remainingGoods.length; i += 2) {
    final left = remainingGoods[i];
    final right = remainingGoods.length > (i + 1)
        ? remainingGoods[i + 1]
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
/// - A4 2×2 format: four labels per A4 page in a 2×2 grid
List<pw.Page> _buildPages(List<pw.Widget> labels, LabelFormat format) {
  final pages = <pw.Page>[];

  if (format == LabelFormat.a6) {
    // A6 format: one label per page
    for (final label in labels) {
      pages.add(_labelPageA6(label));
    }
  } else {
    // A4 2×2 format: four labels per page in a grid
    for (var i = 0; i < labels.length; i += 4) {
      final topLeft = labels[i];
      final topRight = i + 1 < labels.length ? labels[i + 1] : null;
      final bottomLeft = i + 2 < labels.length ? labels[i + 2] : null;
      final bottomRight = i + 3 < labels.length ? labels[i + 3] : null;

      pages.add(_labelPageA4Grid(topLeft, topRight, bottomLeft, bottomRight));
    }
  }

  return pages;
}

/// Create a physical A4 page with 2×2 grid of labels
///
/// A4 is 21.0 × 29.7 cm, each A6 landscape label is 14.8 × 10.5 cm
/// Grid layout: 2 × 14.8 = 29.6 cm (width), 2 × 10.5 = 21.0 cm (height) - perfect fit
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
            _withMeasurements(topLeft),
            _withMeasurements(topRight ?? pw.Container()),
          ],
        ),
        // Bottom row
        pw.Row(
          children: [
            _withMeasurements(bottomLeft ?? pw.Container()),
            _withMeasurements(bottomRight ?? pw.Container()),
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

/// Wrap label with correct measurements
pw.Widget _withMeasurements(pw.Widget label) => pw.Container(
  child: pw.SizedBox(width: 14.8 * cm, height: 10.5 * cm, child: label),
);

/// Build the first label with summary information
Future<pw.Column> _buildFirstLabel(
  PackingList list,
  pw.Widget good,
  int currentPage,
  int numberOfPages,
  PrintContext context,
) async {
  final top = await _buildHeaderForFirstLabel(
    currentPage,
    numberOfPages,
    context,
  );
  return pw.Column(
    children: [
      top,
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _buildSummarySection(list)),
          pw.SizedBox(width: 16),
          pw.Expanded(child: good),
        ],
      ),
    ],
  );
}

/// Build header for the first label
Future<pw.Widget> _buildHeaderForFirstLabel(
  int currentPage,
  int numberOfPages,
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
        child: _buildBox(smallText("Label $currentPage / $numberOfPages")),
        flex: 2,
      ),
    ],
  );
}

/// Build summary section for first label
pw.Widget _buildSummarySection(PackingList list) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      summaryTable(summaryRows(list)),
      pw.Row(
        children: [
          valueBox("Destination:", list.destination),
          valueBox(
            "Seq. build prio:",
            list.sequentialBuild.displayName,
            0.0,
            PdfColor.fromHex(_colorToHex(list.sequentialBuild.color.value)),
          ),
        ],
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
        smallText("Printed by: ${context.userName}"),
        smallText("Date: ${context.formattedDate}"),
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
