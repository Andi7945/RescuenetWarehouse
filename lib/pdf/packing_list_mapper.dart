import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'package:rescuenet_warehouse/pdf/pdf_mapper_utils.dart';
import 'package:rescuenet_warehouse/pdf/print_sorting.dart';

import '../models/container_type.dart';
import '../models/item.dart';
import '../item_utils.dart';
import '../models/rescue_container.dart';
import '../models/sign.dart';

/// Formats container type with measurements.
/// Returns format: "{name} {measurements}" or just name if no measurements.
/// Example: "Euro L60 x W40 x H32"
String _formatContainerType(ContainerType? type) {
  if (type == null) return "";

  final name = type.name;
  final measurements = type.measurements;

  if (measurements.isEmpty) {
    return name;
  }

  return "$name $measurements";
}

/// Maps containers to packing lists.
///
/// The resulting lists are ordered like the summary list
/// (destination priority -> destination -> container number) so that printed
/// stacks of packing lists match the packing order.
List<PackingList> mapPackingList(
  Map<RescueContainer, Map<Item, int>> containerWithItems,
) {
  final entries = containerWithItems.entries.toList()
    ..sort(
      (a, b) => compareContainersForSummary(
        aPriority: a.key.moduleDestination?.priority ?? unprioritisedRank,
        aDestination: a.key.moduleDestination?.name ?? "",
        aNumber: a.key.number,
        bPriority: b.key.moduleDestination?.priority ?? unprioritisedRank,
        bDestination: b.key.moduleDestination?.name ?? "",
        bNumber: b.key.number,
      ),
    );
  return entries.map(_single).toList();
}

PackingList _single(MapEntry<RescueContainer, Map<Item, int>> entry) =>
    PackingList(
      containerNo: entry.key.number,
      containerType: _formatContainerType(entry.key.type),
      containerName: entry.key.printName,
      containerDescription: entry.key.description ?? "",
      totalWeight: sumItemWeight(entry.key, entry.value),
      destination: entry.key.moduleDestination?.name ?? "",
      priority: entry.key.moduleDestination?.priority ?? unprioritisedRank,
      sequentialBuild: entry.key.sequentialBuild,
      expirationDate: nextExpirationDate(entry.value),
      dangerousGoods: _dangerousGoods(
        entry.value.keys.expand((element) => element.signs),
      ),
      items: _items(entry.value),
    );

List<PackingDangerousGood> _dangerousGoods(Iterable<Sign> signs) =>
    signs.map(_singleGood).toList();

/// Build image path for dangerous goods signs.
///
/// Handles two cases:
/// - HTTP URLs (Firebase Storage): return as-is
/// - Local assets (filenames): prepend 'assets/images/'
String _buildImagePath(String? path) {
  if (path == null || path.isEmpty) return "";
  if (path.startsWith("http")) return path; // HTTP URL - return as-is
  return 'assets/images/$path'; // Local asset - prepend directory
}

PackingDangerousGood _singleGood(Sign sign) => PackingDangerousGood(
  dangerType: sign.dangerType ?? "",
  iataId: sign.unNumber ?? "",
  properShippingName: sign.properShippingName ?? "",
  maxWeightPAX: sign.maxWeightPAX,
  maxWeightCargo: sign.maxWeightCargo,
  remarks: sign.remarks ?? "",
  imagePath: _buildImagePath(sign.imagePath),
);

/// Items are ordered: dangerous goods -> cold chain -> heaviest first.
List<PackingItem> _items(Map<Item, int> items) =>
    sortItemsForPackingList(items).map(_singleItem).toList();

PackingItem _singleItem(MapEntry<Item, int> item) => PackingItem(
  name: item.key.name ?? "",
  description: item.key.description ?? "",
  amount: item.value.toDouble(),
  piecePrice: item.key.value.toDouble(),
  weightTotal: item.key.weight * item.value,
  expirationDate: nextExpirationDateSingle(item),
  dangerousGoods: item.key.signs.map((e) => e.unNumber).join(","),
  remarks: item.key.remarks ?? "",
);
