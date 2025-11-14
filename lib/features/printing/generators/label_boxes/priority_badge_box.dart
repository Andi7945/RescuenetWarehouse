import 'package:pdf/widgets.dart' as pw;
import 'package:rescuenet_warehouse/pdf/packing_list.dart';

import '../common/pdf_base_widgets.dart';
import '../common/priority_badge_widget.dart';
import '../label_generator.dart';

/// Box 4: Priority badge (bottom-center, no border)
class PriorityBadgeBox {
  final PackingList list;

  const PriorityBadgeBox({required this.list});

  pw.Widget build() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: buildPriorityBadge(
          priority: list.priority,
          destination: list.destination,
          widthCm: LabelCoordinates.w(450) / cm,  // Convert points to cm
          heightCm: LabelCoordinates.h(450) / cm, // Convert points to cm
        ),
      ),
    );
  }
}
