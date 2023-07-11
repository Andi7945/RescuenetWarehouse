import 'container_type.dart';
import 'sequential_build.dart';

class ContainerOptions {
  final List<ContainerType> types;
  final List<String> moduleDestinations;
  final List<String> currentLocations;
  final List<String> sequentialBuilds =
      SequentialBuild.values.map((e) => e.name).toList();

  ContainerOptions(this.types, this.moduleDestinations, this.currentLocations);
}
