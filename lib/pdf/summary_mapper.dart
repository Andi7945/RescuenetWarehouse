import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';

import '../models/item.dart';
import '../item_utils.dart';
import '../models/rescue_container.dart';
import 'pdf_mapper_utils.dart';
import 'print_sorting.dart';
import 'summary_container.dart';

/// Builds the summary PDF data.
///
/// Containers are ordered by module destination priority (1 -> 4), then
/// grouped per destination and finally by container number.
SummaryPdf mapForPdf(Map<RescueContainer, Map<Item, int>> containerWithItems) {
  var containers = containerWithItems.entries.map(_mapSingle).toList()
    ..sort(
      (a, b) => compareContainersForSummary(
        aPriority: a.priority,
        aDestination: a.moduleDestination,
        aNumber: a.containerNr,
        bPriority: b.priority,
        bDestination: b.moduleDestination,
        bNumber: b.containerNr,
      ),
    );
  return SummaryPdf(list: _list(containers), containers: containers);
}

SummaryList _list(List<SummaryContainer> containers) {
  var totalValue = containers.fold(0, (prev, c) => prev + c.value);
  var totalWeight = containers.fold(0.0, (prev, c) => prev + c.weight);
  var amountPerType = containers
      .groupBy((c) => c.type)
      .mapValues((p0) => "${p0.length}");
  return SummaryList(
    count: "${containers.length}",
    amountPerType: amountPerType,
    totalValue: totalValue,
    totalWeight: totalWeight,
  );
}

SummaryContainer _mapSingle(MapEntry<RescueContainer, Map<Item, int>> entry) =>
    SummaryContainer(
      containerNr: entry.key.number,
      name: entry.key.printName,
      description: entry.key.description ?? "",
      type: entry.key.type?.name ?? "",
      value: calcValue(entry.value),
      weight: _calcWeight(entry),
      expirationDate: nextExpirationDateFormatted(entry.value),
      dangerousGoods: _dangerousGoods(entry.value),
      coldChain: _hasColdChainItem(entry.value),
      moduleDestination: entry.key.moduleDestination?.name ?? "",
      priority: entry.key.moduleDestination?.priority ?? unprioritisedRank,
      sequentialBuild: entry.key.sequentialBuild,
    );

/// Text representation of the container's dangerous goods for the summary
/// table cell.
///
/// Prefers UN numbers, which are the useful identifier for a loader. Signs
/// carrying only a placard image have no UN number, so they fall back to
/// "Yes" - an empty cell must mean "no dangerous goods", never "dangerous
/// but undescribed".
String _dangerousGoods(Map<Item, int> items) {
  final unNumbers = items.keys
      .expand((i) => i.signs)
      .map((s) => s.unNumber)
      .nonNulls
      .where((un) => un.isNotEmpty)
      .toSet();

  if (unNumbers.isNotEmpty) return unNumbers.join(",");

  return items.keys.any(isDangerousGoodsItem) ? "Yes" : "";
}

_hasColdChainItem(Map<Item, int> items) =>
    items.keys.any(isColdChainItem) ? "Yes" : "";

_calcWeight(MapEntry<RescueContainer, Map<Item, int>> entry) =>
    sumItemWeight(entry.key, entry.value);
