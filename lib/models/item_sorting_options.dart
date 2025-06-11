import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/item.dart';

part 'item_sorting_options.freezed.dart';

List<ItemSortingOption> itemSortingOptions = [
  ItemSortingOption(
    displayName: "Name",
    value: (item) => item.name,
    sort: _createSortFn((itm) => itm.name),
  ),
  ItemSortingOption(
    displayName: "Brand",
    value: (item) => item.brand,
    sort: _createSortFn((itm) => itm.brand),
  ),
  ItemSortingOption(
    displayName: "RescueNet ID",
    value: (item) => item.rescueNetId.toString(),
    sort: (a, b) => a.rescueNetId.compareTo(b.rescueNetId),
  ),
  ItemSortingOption(
    displayName: "Description",
    value: (item) => item.description,
    sort: _createSortFn((itm) => itm.description),
  ),
  ItemSortingOption(
    displayName: "Manufacturer",
    value: (item) => item.manufacturer,
    sort: _createSortFn((itm) => itm.manufacturer),
  ),
  ItemSortingOption(
    displayName: "Type",
    value: (item) => item.type,
    sort: _createSortFn((itm) => itm.type),
  ),
  ItemSortingOption(
    displayName: "Supplier",
    value: (item) => item.supplier,
    sort: _createSortFn((itm) => itm.supplier),
  ),
  ItemSortingOption(
    displayName: "Website",
    value: (item) => item.website,
    sort: _createSortFn((itm) => itm.website),
  ),
  ItemSortingOption(
    displayName: "Weight",
    value: (item) => item.weight.toString(),
    sort: (a, b) => a.weight.compareTo(b.weight),
  ),
];

@freezed
abstract class ItemSortingOption with _$ItemSortingOption {
  const factory ItemSortingOption({
    required String displayName,
    required String? Function(Item item) value,
    required int Function(Item a, Item b) sort,
    @Default(true) bool asc,
  }) = _ItemSortingOption;
}

int Function(Item a, Item b) _createSortFn(String? Function(Item) fn) {
  return (a, b) => (fn(a) ?? "").compareTo(fn(b) ?? "");
}
