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
