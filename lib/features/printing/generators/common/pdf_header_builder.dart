import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';
import 'pdf_base_widgets.dart';

/// Build header with organization info and user context

/// Build header row with left content and right side org info
Future<pw.Widget> buildHeaderRow(
  pw.Widget leftCorner,
  pw.Widget? rightSide,
  PrintContext context,
) async {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: leftCorner, flex: 5),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: await _buildRightSide(rightSide, context),
          flex: 5,
        ),
      ],
    ),
  );
}

/// Build the right side with org info and optional additional content
Future<pw.Widget> _buildRightSide(
  pw.Widget? rightSide,
  PrintContext context,
) async {
  return pw.Container(
    width: double.infinity,
    child: pw.Column(
      children: [
        await _buildOrgInfoBox(context),
        pw.SizedBox(height: 8),
        rightSide ?? pw.Container(),
      ],
    ),
  );
}

/// Build organization info box with logo and contact details
Future<pw.Widget> _buildOrgInfoBox(PrintContext context) async {
  final logo = await loadImage(context.logoAssetPath);

  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(right: 8.0),
          child: _buildInfoBox(context),
        ),
        flex: 2,
      ),
      pw.Expanded(child: logo, flex: 3),
    ],
  );
}

/// Build the info box with contact details and print metadata
pw.Widget _buildInfoBox(PrintContext context) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4.0),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        smallText(context.organizationEmail),
        smallText(context.organizationPhone),
        pw.SizedBox(height: 10),
        smallText('Printed by: ${context.userName}'),
        smallText('Date: ${context.formattedDate}'),
      ],
    ),
  );
}

/// Build footer with page numbers
pw.Widget Function(int, int) buildFooter(String documentName) {
  return (int pageNum, int totalPages) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('$documentName - page $pageNum / $totalPages'),
      );
}
