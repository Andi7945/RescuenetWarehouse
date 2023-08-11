import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/module_destination.dart';

import 'container_type.dart';
import 'sequential_build.dart';

class ContainerOptions {
  final List<ContainerType> types;
  final List<ModuleDestination> moduleDestinations;
  final List<CurrentLocation> currentLocations;
  final List<String> sequentialBuilds =
      SequentialBuild.values.map((e) => e.name).toList();

  ContainerOptions(this.types, this.moduleDestinations, this.currentLocations);
}
