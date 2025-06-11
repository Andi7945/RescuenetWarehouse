enum FilterField {
  all(displayName: "Everywhere"),
  containerName(displayName: "Container name"),
  containerLocation(displayName: "Current location"),
  containerDestination(displayName: "Module destination"),
  containerType(displayName: "Container type"),
  containerSequentialBuild(displayName: "Sequential build"),
  itemName(displayName: "Name"),
  itemNotes(displayName: "Notes"),
  itemRescueNetId(displayName: "RescueNet ID"),
  itemDescription(displayName: "Description"),
  itemHasExpiringDates(
      displayName: "Has exp dates", applyToEverywhere: false),
  itemOperationalStatus(displayName: "Op status"),
  itemManufacturer(displayName: "Manufacturer"),
  itemBrand(displayName: "Brand"),
  itemType(displayName: "Type"),
  itemSupplier(displayName: "Supplier"),
  itemWebsite(displayName: "Website"),
  itemWeight(displayName: "Weight");

  const FilterField({required this.displayName, this.applyToEverywhere = true});

  final String displayName;
  final bool applyToEverywhere;
}
