import 'package:rescuenet_warehouse/sequential_build.dart';

class SummaryContainer {
  final double containerNr;
  final String name;
  final String description;
  final String type;
  final int value;
  final double weight;
  final String expirationDate;
  final String dangerousGoods;
  final String coldChain;
  final String moduleDestination;
  final SequentialBuild sequentialBuild;

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
      this.sequentialBuild);
}