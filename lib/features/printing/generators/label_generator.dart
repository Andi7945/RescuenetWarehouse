import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

import 'common/pdf_base_widgets.dart';

/// Convert Flutter color int to hex string for PDF
String _colorToHex(int color) {
  return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Generate container label PDF document
Future<pw.Document> generateLabelPdf(
  PackingList packingList,
  PrintContext context,
) async {
  final pdf = pw.Document();

  final goods = await dangerousGoodsLabels(packingList.dangerousGoods);
  final totalPages = (goods.length / 2).floor() + 1;

  // Build all label pages
  final pages = await _buildAllPages(packingList, goods, totalPages, context);

  for (final page in pages) {
    pdf.addPage(page);
  }

  return pdf;
}

/// Build all label pages
Future<List<pw.Page>> _buildAllPages(
  PackingList list,
  List<pw.Widget> goods,
  int totalPages,
  PrintContext context,
) async {
  // First page: one dangerous good plus summary info
  final l1 = await _buildFirstLabel(list, goods.first, 1, totalPages, context);

  // Additional pages: two dangerous goods per page
  final additional = goods.skip(1).toList();
  final additionalLabels = <pw.Widget>[];

  for (var i = 0; i < additional.length; i += 2) {
    var left = additional[i];
    var right = additional.length > (i + 1)
        ? additional[i + 1]
        : pw.Container();
    additionalLabels.add(
      await _buildSubsequentLabel(
        left,
        right,
        (i / 2).floor() + 2,
        totalPages,
        list.containerNo,
        context,
      ),
    );
  }

  // Build physical pages (two labels per page)
  final pages = <pw.Page>[];

  // First physical page
  if (additionalLabels.isNotEmpty) {
    pages.add(_labelPage(l1, additionalLabels.first));
  } else {
    pages.add(_labelPage(l1, null));
  }

  // Subsequent physical pages
  final others = additionalLabels.skip(1).toList();
  for (var i = 0; i < others.length; i += 2) {
    final second = (i + 1) < others.length ? others[i + 1] : null;
    pages.add(_labelPage(others[i], second));
  }

  return pages;
}

/// Create a physical page with two labels
pw.Page _labelPage(pw.Widget w, pw.Widget? w2) => pw.MultiPage(
  build: (pw.Context context) => [
    _withMeasurements(w),
    _withMeasurements(w2 ?? pw.Container()),
  ],
);

/// Wrap label with correct measurements
pw.Widget _withMeasurements(pw.Widget label) => pw.Container(
  child: pw.SizedBox(width: 14.8 * cm, height: 10.51 * cm, child: label),
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
