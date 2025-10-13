import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary_list.freezed.dart';

@freezed
abstract class SummaryList with _$SummaryList {
  const factory SummaryList({
    required String count,
    required Map<String, String> amountPerType,
    required int totalValue,
    required double totalWeight,
  }) = _SummaryList;
}
