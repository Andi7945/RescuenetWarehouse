import 'package:rescuenet_warehouse/filter_fields.dart';
import 'package:rescuenet_warehouse/models/item.dart';

class ItemFilter {
  final FilterField _field;
  final bool Function(Item, String) _check;

  String get displayName => _field.displayName;

  bool check(Item itm, String v) => _check(itm, v);

  ItemFilter(this._field, this._check);
}

var allItemFilter = {
  FilterField.itemName: ItemFilter(FilterField.itemName,
      (Item itm, String value) => _contains(itm.name, value)),
  FilterField.itemNotes: ItemFilter(FilterField.itemNotes,
      (Item itm, String value) => _contains(itm.notes, value)),
  FilterField.itemRescueNetId: ItemFilter(FilterField.itemRescueNetId,
      (Item itm, String value) => itm.rescueNetId.toString().startsWith(value)),
  FilterField.itemDescription: ItemFilter(FilterField.itemDescription,
      (Item itm, String value) => _contains(itm.description, value)),
  FilterField.itemHasExpiringDates: ItemFilter(FilterField.itemHasExpiringDates,
      (Item itm, _) => itm.expiringDates.isNotEmpty),
  FilterField.itemOperationalStatus: ItemFilter(
      FilterField.itemOperationalStatus,
      (Item itm, String value) =>
          itm.operationalStatus.toString().contains(value)),
  FilterField.itemManufacturer: ItemFilter(FilterField.itemManufacturer,
      (Item itm, String value) => _contains(itm.manufacturer, value)),
  FilterField.itemBrand: ItemFilter(FilterField.itemBrand,
      (Item itm, String value) => _contains(itm.brand, value)),
  FilterField.itemType: ItemFilter(FilterField.itemType,
      (Item itm, String value) => _contains(itm.type, value)),
  FilterField.itemSupplier: ItemFilter(FilterField.itemSupplier,
      (Item itm, String value) => _contains(itm.supplier, value)),
  FilterField.itemWebsite: ItemFilter(FilterField.itemWebsite,
      (Item itm, String value) => _contains(itm.website, value)),
};

bool _contains(String? field, String value) =>
    field != null && field.toLowerCase().contains(value.toLowerCase());
