import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'package:rescuenet_warehouse/pdf/pdf_mapper_utils.dart';

import '../item.dart';
import '../item_utils.dart';
import '../rescue_container.dart';
import '../sign.dart';

List<PackingList> mapPackingList(
    Map<RescueContainer, Map<Item, int>> containerWithItems) {
  return containerWithItems.entries.map(_single).toList();
}

PackingList _single(MapEntry<RescueContainer, Map<Item, int>> entry) =>
    PackingList(
        entry.key.number,
        entry.key.type?.name ?? "",
        entry.key.name,
        entry.key.description ?? "",
        sumItemWeight(entry.key, entry.value),
        entry.key.moduleDestination?.name ?? "",
        entry.key.sequentialBuild,
        nextExpirationDate(entry.value),
        _dangerousGoods(entry.value.keys.expand((element) => element.signs)),
        _items(entry.value));

List<PackingDangerousGood> _dangerousGoods(Iterable<Sign> signs) =>
    signs.map(_singleGood).toList();

PackingDangerousGood _singleGood(Sign sign) => PackingDangerousGood(
    sign.dangerType ?? "",
    sign.unNumber ?? "",
    sign.properShippingName ?? "",
    sign.maxWeightPAX,
    sign.maxWeightCargo,
    sign.remarks ?? "",
    sign.imagePath ?? "");

List<PackingItem> _items(Map<Item, int> items) =>
    items.entries.map(_singleItem).toList();

PackingItem _singleItem(MapEntry<Item, int> item) => PackingItem(
    item.key.name ?? "",
    item.key.description ?? "",
    item.value.toDouble(),
    item.key.value.toDouble(),
    item.key.weight * item.value,
    nextExpirationDateSingle(item),
    item.key.signs.map((e) => e.unNumber).join(","),
    "item.key.remarks");
