import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/features/printing/domain/print_context.dart';

import '../common/pdf_base_widgets.dart';

/// Box 1: Contact information and print metadata (top-left, with border)
class ContactInfoBox {
  final PrintContext context;

  const ContactInfoBox({required this.context});

  pw.Widget build() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
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
}
