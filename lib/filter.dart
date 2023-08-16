import 'item.dart';
import 'rescue_container.dart';

class Filter {
  final FilterField field;
  final String? value;
  final bool Function(RescueContainer, Iterable<Item>) fn;

  Filter(this.field, this.value) : fn = calcFn(field, value);
}

bool Function(RescueContainer, Iterable<Item>) calcFn(
    FilterField field, String? value) {
  if (value == null || value.isEmpty) {
    return (c, i) => true;
  }
  Map<FilterField, String? Function(RescueContainer)> containerFilters = {
    FilterField.containerName: (c) => c.name,
    FilterField.containerLocation: (c) => c.currentLocation?.name,
    FilterField.containerDestination: (c) => c.moduleDestination?.name,
    FilterField.containerType: (c) => c.type?.name,
    FilterField.containerSequentialBuild: (c) => c.sequentialBuild.displayName
  };

  var containerFilterBuilder = containerFilters[field];
  if (containerFilterBuilder != null) {
    return (c, _) => contains(containerFilterBuilder(c), value);
  }

  Map<FilterField, String? Function(Item)> itemFilters = {
    FilterField.itemName: (itm) => itm.name,
    FilterField.itemNotes: (itm) => itm.notes,
    FilterField.itemDescription: (itm) => itm.description,
    FilterField.itemOperationalStatus: (itm) => itm.operationalStatus.displayName,
    FilterField.itemManufacturer: (itm) => itm.manufacturer,
    FilterField.itemBrand: (itm) => itm.brand,
    FilterField.itemType: (itm) => itm.type,
    FilterField.itemSupplier: (itm) => itm.supplier,
    FilterField.itemWebsite: (itm) => itm.website
  };
  var itemFilterBuilder = itemFilters[field];
  if (itemFilterBuilder != null) {
    return (_, i) => i.any((itm) => contains(itemFilterBuilder(itm), value));
  }

  if (field == FilterField.itemRescueNetId) {
    return (_, i) =>
        i.any((itm) => itm.rescueNetId.toString().startsWith(value));
  }

  if (field == FilterField.itemHasExpiringDates) {
    return (_, i) => i.any((element) => element.expiringDates.isNotEmpty);
  }
  return (c, i) => true;
}

bool contains(String? field, String value) =>
    field != null && field.toLowerCase().contains(value.toLowerCase());

enum FilterField {
  containerName(displayName: "Container name"),
  containerLocation(displayName: "Current location"),
  containerDestination(displayName: "Module destination"),
  containerType(displayName: "Container type"),
  containerSequentialBuild(displayName: "Sequential build"),
  itemName(displayName: "Item name"),
  itemNotes(displayName: "Item notes"),
  itemRescueNetId(displayName: "Item RescueNet ID"),
  itemDescription(displayName: "Item description"),
  itemHasExpiringDates(displayName: "Item has exp dates"),
  itemOperationalStatus(displayName: "Item op status"),
  itemManufacturer(displayName: "Item manufacturer"),
  itemBrand(displayName: "Item brand"),
  itemType(displayName: "Item type"),
  itemSupplier(displayName: "Item supplier"),
  itemWebsite(displayName: "Item website");

  const FilterField({required this.displayName});

  final String displayName;
}
