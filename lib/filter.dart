import 'rescue_container.dart';

class Filter {
  final FilterField field;
  final String? value;
  final bool Function(RescueContainer) fn;

  Filter(this.field, this.value) : fn = calcFn(field, value);
}

calcFn(FilterField field, String? value) {
  if (value == null) {
    return true;
  }
  if (field == FilterField.containerName) {
    return (RescueContainer a) => contains(a.name, value);
  }
  if (field == FilterField.containerLocation) {
    return (RescueContainer a) => contains(a.currentLocation?.name, value);
  }
  if (field == FilterField.containerDestination) {
    return (RescueContainer c) => contains(c.moduleDestination?.name, value);
  }
  if (field == FilterField.containerType) {
    return (RescueContainer c) => contains(c.type?.name, value);
  }
  if (field == FilterField.containerSequentialBuild) {
    return (RescueContainer c) => contains(c.sequentialBuild.name, value);
  }
  return true;
}

bool contains(String? field, String value) =>
    field != null && field.toLowerCase().contains(value.toLowerCase());

enum FilterField {
  containerName(displayName: "Container Name"),
  containerLocation(displayName: "Current Location"),
  containerDestination(displayName: "Module Destination"),
  containerType(displayName: "Container Type"),
  containerSequentialBuild(displayName: "Sequential Build");

  const FilterField({required this.displayName});

  final String displayName;
}
