import 'package:rescuenet_warehouse/filter_fields.dart';
import 'package:rescuenet_warehouse/item_filter.dart';

import 'models/item.dart';
import 'models/rescue_container.dart';

class ContainerFilter {
  final FilterField field;
  final String? value;
  final bool Function(RescueContainer, Iterable<Item>, String?) fn;

  ContainerFilter(this.field, this.value) : fn = calcFn(field);

  ContainerFilter.filled(this.field, this.value, this.fn);

  ContainerFilter withNewValue(String? value) {
    return ContainerFilter(field, value);
  }

  bool matches(RescueContainer cont, Iterable<Item> itms) =>
      fn(cont, itms, value);
}

bool Function(RescueContainer, Iterable<Item>, String?) calcFn(
    FilterField field) {
  return (c, itms, value) {
    if (field == FilterField.itemHasExpiringDates) {
      return itms.any((itm) => allItemFilter[field]!.check(itm, ""));
    }

    if (value == null || value.isEmpty) {
      return true;
    }

    if (field == FilterField.all) {
      return containerFilterMatches(value, field)(c, itms) ||
          itms.any((itm) => allItemFilter.entries
              .where((e) => e.key.applyToEverywhere)
              .any((e) => e.value.check(itm, value)));
    }

    var itemFilter = allItemFilter[field];

    return containerFilterMatches(value, field)(c, itms) ||
        (itemFilter == null || itms.any((itm) => itemFilter.check(itm, value)));
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

bool contains(String? field, String value) =>
    field != null && field.toLowerCase().contains(value.toLowerCase());
