import 'package:rescuenet_warehouse/pdf/summary_list.dart';

import 'summary_container.dart';

class SummaryPdf {
  final SummaryList list;
  final List<SummaryContainer> containers;

  SummaryPdf(this.list, this.containers);
}