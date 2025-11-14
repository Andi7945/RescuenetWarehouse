import 'package:pdf/widgets.dart' as pw;

import '../label_generator.dart';

/// Box 2: Organization logo (bottom-left, no border)
class LogoBox {
  final pw.ImageProvider logo;

  const LogoBox({required this.logo});

  pw.Widget build() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Image(
          logo,
          height: LabelCoordinates.h(500), // Scale logo proportionally
          fit: pw.BoxFit.contain,
        ),
      ),
    );
  }
}
