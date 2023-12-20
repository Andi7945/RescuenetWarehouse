import 'package:rescuenet_warehouse/models/item.dart';

List<ItemSortingOption> itemSortingOptions = [
  ItemSortingOption(
      displayName: "Name", sort: _createSortFn((itm) => itm.name)),
  ItemSortingOption(
      displayName: "Brand", sort: _createSortFn((itm) => itm.brand)),
  ItemSortingOption(
      displayName: "RescueNet ID",
      sort: (a, b) => a.rescueNetId.compareTo(b.rescueNetId)),
  ItemSortingOption(
      displayName: "Description",
      sort: _createSortFn((itm) => itm.description)),
  ItemSortingOption(
      displayName: "Manufacturer",
      sort: _createSortFn((itm) => itm.manufacturer)),
  ItemSortingOption(
      displayName: "Type", sort: _createSortFn((itm) => itm.type)),
  ItemSortingOption(
      displayName: "Supplier", sort: _createSortFn((itm) => itm.supplier)),
  ItemSortingOption(
      displayName: "Website", sort: _createSortFn((itm) => itm.website)),
];

class ItemSortingOption {
  ItemSortingOption({required this.displayName, required this.sort});

  final String displayName;
  final int Function(Item a, Item b) sort;
}

int Function(Item a, Item b) _createSortFn(String? Function(Item) fn) {
  return (a, b) => (fn(a) ?? "").compareTo(fn(b) ?? "");
}
