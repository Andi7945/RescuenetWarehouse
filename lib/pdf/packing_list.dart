import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';
import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';

part 'packing_list.freezed.dart';

@freezed
abstract class PackingList with _$PackingList {
  const factory PackingList({
    required int containerNo,
    required String containerType,
    required String containerName,
    required String containerDescription,
    required double totalWeight,
    required String destination,
    required int priority,
    required SequentialBuild sequentialBuild,
    required DateTime? expirationDate,
    required List<PackingDangerousGood> dangerousGoods,
    required List<PackingItem> items,
  }) = _PackingList;
}
