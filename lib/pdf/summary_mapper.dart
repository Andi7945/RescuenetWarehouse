import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/pdf/summary_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_pdf.dart';

import '../item.dart';
import '../item_utils.dart';
import '../rescue_container.dart';
import 'pdf_mapper_utils.dart';
import 'summary_container.dart';

SummaryPdf mapForPdf(Map<RescueContainer, Map<Item, int>> containerWithItems) {
  var containers = containerWithItems.entries.map(_mapSingle).toList();
  return SummaryPdf(_list(containers), containers);
}

SummaryList _list(List<SummaryContainer> containers) {
  var totalValue = containers.fold(0, (prev, c) => prev + c.value);
  var totalWeight = containers.fold(0.0, (prev, c) => prev + c.weight);
  var amountPerType =
      containers.groupBy((c) => c.type).mapValues((p0) => "${p0.length}");
  return SummaryList(
      "${containers.length}", amountPerType, totalValue, totalWeight);
}

SummaryContainer _mapSingle(MapEntry<RescueContainer, Map<Item, int>> entry) =>
    SummaryContainer(
        entry.key.id,
        entry.key.name,
        "description",
        entry.key.type?.name ?? "",
        calcValue(entry.value),
        _calcWeight(entry),
        nextExpirationDateFormatted(entry.value),
        _dangerousGoods(entry.value),
        _hasColdChainItem(entry.value),
        entry.key.moduleDestination?.name ?? "",
        entry.key.sequentialBuild);

_dangerousGoods(Map<Item, int> items) => items.keys
    .expand((e) => e.signs)
    .map((e) => e.remarks)
    .where((e) => e != null)
    .toSet()
    .join(",");

_hasColdChainItem(Map<Item, int> items) {
  var isColdChain = items.keys
      .where((itm) => itm.signs.where((s) => s.id == "2").isNotEmpty)
      .isNotEmpty;

  return isColdChain ? "Yes" : "";
}

_calcWeight(MapEntry<RescueContainer, Map<Item, int>> entry) =>
    sumItemWeight(entry.key, entry.value);
