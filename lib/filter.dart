import 'models/item.dart';
import 'models/rescue_container.dart';

class Filter {
  final FilterField field;
  final String? value;
  final bool Function(RescueContainer, Iterable<Item>, String?) fn;

  Filter(this.field, this.value) : fn = calcFn(field);

  Filter.filled(this.field, this.value, this.fn);

  Filter withNewValue(String? value) {
    return Filter(field, value);
  }

  bool matches(RescueContainer cont, Iterable<Item> itms) =>
      fn(cont, itms, value);
}

bool Function(RescueContainer, Iterable<Item>, String?) calcFn(
    FilterField field) {
  return (c, i, value) {
    if (value == null || value.isEmpty) {
      return true;
    }

    return containerFilterMatches(value, field)(c, i) ||
        itemFilterMatches(value, field)(c, i) ||
        rescueIdFilterMatches(value, field)(c, i) ||
        hasExpiringDatesMatches(value, field)(c, i);
  };
}

bool Function(RescueContainer, Iterable<Item>) containerFilterMatches(
    String value, FilterField field) {
  Map<FilterField, String? Function(RescueContainer)> containerFilters = {
    FilterField.containerName: (c) => c.printName,
    FilterField.containerLocation: (c) => c.currentLocation?.name,
    FilterField.containerDestination: (c) => c.moduleDestination?.name,
    FilterField.containerType: (c) => c.type?.name,
    FilterField.containerSequentialBuild: (c) => c.sequentialBuild.displayName
  };

  if (field == FilterField.all) {
    return (c, _) =>
        containerFilters.values.any((element) => contains(element(c), value));
  }
  var containerFilterBuilder = containerFilters[field];
  if (containerFilterBuilder != null) {
    return (c, _) => contains(containerFilterBuilder(c), value);
  }
  return (c, _) => false;
}

bool Function(RescueContainer, Iterable<Item>) itemFilterMatches(
    String value, FilterField field) {
  Map<FilterField, String? Function(Item)> itemFilters = {
    FilterField.itemName: (itm) => itm.name,
    FilterField.itemNotes: (itm) => itm.notes,
    FilterField.itemDescription: (itm) => itm.description,
    FilterField.itemOperationalStatus: (itm) =>
        itm.operationalStatus.displayName,
    FilterField.itemManufacturer: (itm) => itm.manufacturer,
    FilterField.itemBrand: (itm) => itm.brand,
    FilterField.itemType: (itm) => itm.type,
    FilterField.itemSupplier: (itm) => itm.supplier,
    FilterField.itemWebsite: (itm) => itm.website
  };
  if (field == FilterField.all) {
    return (_, i) =>
        itemFilters.values.any((f) => i.any((itm) => contains(f(itm), value)));
  }

  var itemFilterBuilder = itemFilters[field];
  if (itemFilterBuilder != null) {
    return (_, i) => i.any((itm) => contains(itemFilterBuilder(itm), value));
  }

  return (_, i) => false;
}

bool Function(RescueContainer, Iterable<Item>) rescueIdFilterMatches(
    String value, FilterField field) {
  if (field == FilterField.itemRescueNetId || field == FilterField.all) {
    return (_, i) =>
        i.any((itm) => itm.rescueNetId.toString().startsWith(value));
  }
  return (_, i) => false;
}

bool Function(RescueContainer, Iterable<Item>) hasExpiringDatesMatches(
    String value, FilterField field) {
  if (field == FilterField.itemHasExpiringDates) {
    return (_, i) => i.any((element) => element.expiringDates.isNotEmpty);
  }

  return (_, i) => false;
}

bool contains(String? field, String value) =>
    field != null && field.toLowerCase().contains(value.toLowerCase());

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
