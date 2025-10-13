import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_container.dart';

part 'summary_pdf.freezed.dart';

@freezed
abstract class SummaryPdf with _$SummaryPdf {
  const factory SummaryPdf({
    required SummaryList list,
    required List<SummaryContainer> containers,
  }) = _SummaryPdf;
}
