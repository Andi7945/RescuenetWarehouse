import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Handles print dialog interactions
class PrintService {
  /// Show native print dialog for a single PDF
  static Future<void> showPrintDialog(
    Uint8List pdfBytes, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    await Printing.layoutPdf(
      format: format,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Show print dialog for multiple PDFs (prints one by one)
  static Future<void> showPrintDialogForMultiple(
    List<Uint8List> pdfBytesList, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    for (final bytes in pdfBytesList) {
      await showPrintDialog(bytes, format: format);
    }
  }
}
