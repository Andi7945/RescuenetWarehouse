class SummaryContainer {
  final String containerNr;
  final String name;
  final String description;
  final String type;
  final String value;
  final String weight;
  final String expirationDate;
  final String dangerousGoods;
  final String coldChain;
  final String moduleDestination;
  final String sequentialBuildPriority;

  SummaryContainer(
      this.containerNr,
      this.name,
      this.description,
      this.type,
      this.value,
      this.weight,
      this.expirationDate,
      this.dangerousGoods,
      this.coldChain,
      this.moduleDestination,
      this.sequentialBuildPriority);
}