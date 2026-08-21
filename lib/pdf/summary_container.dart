import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';

part 'summary_container.freezed.dart';

@freezed
abstract class SummaryContainer with _$SummaryContainer {
  const factory SummaryContainer({
    required int containerNr,
    required String name,
    required String description,
    required String type,
    required int value,
    required double weight,
    required String expirationDate,
    required String dangerousGoods,
    required String coldChain,
    required String moduleDestination,
    required int priority,
    required SequentialBuild sequentialBuild,
  }) = _SummaryContainer;
}
