import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/store.dart';
import 'package:rescuenet_warehouse/summary_list.dart';
import 'package:rescuenet_warehouse/summary_pdf.dart';

import 'item.dart';
import 'rescue_container.dart';
import 'summary_container.dart';

import 'package:intl/intl.dart';

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
        entry.key.type.name,
        _calcValue(entry.value),
        _calcWeight(entry),
        _nextExpirationDate(entry.value),
        _dangerousGoods(entry.value),
        _hasColdChainItem(entry.value),
        entry.key.moduleDestination ?? "",
        entry.key.sequentialBuild.name);

_calcValue(Map<Item, int> items) => items.entries.fold(
    0,
    (previousValue, itmWithCount) =>
        previousValue + itmWithCount.key.value * itmWithCount.value);

final DateFormat formatter = DateFormat('MMM yy');

_nextExpirationDate(Map<Item, int> items) {
  var starTrek = DateTime.utc(9999);

  var nextDate = items.keys.expand((e) => e.expiringDates).fold(starTrek,
      (previousValue, element) {
    if (element.isBefore(previousValue)) {
      return element;
    }
    return previousValue;
  });

  if (nextDate == starTrek) {
    return "";
  }
  return formatter.format(nextDate);
}

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
    sumItemWeight(entry.key, entry.value.keys);
