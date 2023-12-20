import 'package:rescuenet_warehouse/models/item.dart';

enum FilterField {
  all(displayName: "Everywhere"),
  containerName(displayName: "Container name"),
  containerLocation(displayName: "Current location"),
  containerDestination(displayName: "Module destination"),
  containerType(displayName: "Container type"),
  containerSequentialBuild(displayName: "Sequential build"),
  itemName(displayName: "Item name"),
  itemNotes(displayName: "Item notes"),
  itemRescueNetId(displayName: "Item RescueNet ID"),
  itemDescription(displayName: "Item description"),
  itemHasExpiringDates(
      displayName: "Item has exp dates", applyToEverywhere: false),
  itemOperationalStatus(displayName: "Item op status"),
  itemManufacturer(displayName: "Item manufacturer"),
  itemBrand(displayName: "Item brand"),
  itemType(displayName: "Item type"),
  itemSupplier(displayName: "Item supplier"),
  itemWebsite(displayName: "Item website");

  const FilterField({required this.displayName, this.applyToEverywhere = true});

  final String displayName;
  final bool applyToEverywhere;
}

class _Filter {
  final FilterField _field;
  final bool Function(Item, String) _check;

  String get displayName => _field.displayName;

  bool check(Item itm, String v) => _check(itm, v);

  _Filter(this._field, this._check);
}

var allItemFilter = {
  FilterField.itemName: _Filter(FilterField.itemName,
      (Item itm, String value) => _contains(itm.name, value)),
  FilterField.itemNotes: _Filter(FilterField.itemNotes,
      (Item itm, String value) => _contains(itm.notes, value)),
  FilterField.itemRescueNetId: _Filter(FilterField.itemRescueNetId,
      (Item itm, String value) => itm.rescueNetId.toString().startsWith(value)),
  FilterField.itemDescription: _Filter(FilterField.itemDescription,
      (Item itm, String value) => _contains(itm.description, value)),
  FilterField.itemHasExpiringDates: _Filter(FilterField.itemHasExpiringDates,
      (Item itm, _) => itm.expiringDates.isNotEmpty),
  FilterField.itemOperationalStatus: _Filter(
      FilterField.itemOperationalStatus,
      (Item itm, String value) =>
          itm.operationalStatus.toString().contains(value)),
  FilterField.itemManufacturer: _Filter(FilterField.itemManufacturer,
      (Item itm, String value) => _contains(itm.manufacturer, value)),
  FilterField.itemBrand: _Filter(FilterField.itemBrand,
      (Item itm, String value) => _contains(itm.brand, value)),
  FilterField.itemType: _Filter(FilterField.itemType,
      (Item itm, String value) => _contains(itm.type, value)),
  FilterField.itemSupplier: _Filter(FilterField.itemSupplier,
      (Item itm, String value) => _contains(itm.supplier, value)),
  FilterField.itemWebsite: _Filter(FilterField.itemWebsite,
      (Item itm, String value) => _contains(itm.website, value)),
};

bool _contains(String? field, String value) =>
    field != null && field.toLowerCase().contains(value.toLowerCase());
