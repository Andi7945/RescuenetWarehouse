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
    return (RescueContainer a) =>
        a.name.toLowerCase().contains(value.toLowerCase());
  }
  if (field == FilterField.containerLocation) {
    return (RescueContainer a) =>
        a.currentLocation != null &&
        a.currentLocation!.name.toLowerCase().contains(value.toLowerCase());
  }
  if (field == FilterField.containerDestination) {
    return (RescueContainer c) =>
        c.moduleDestination != null &&
        c.moduleDestination!.name.toLowerCase().contains(value.toLowerCase());
  }
  return true;
}

enum FilterField {
  containerName(displayName: "Container Name"),
  containerLocation(displayName: "Current Location"),
  containerDestination(displayName: "Module Destination");

  const FilterField({required this.displayName});

  final String displayName;
}
