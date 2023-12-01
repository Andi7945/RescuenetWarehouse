import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';

import 'models/container_type.dart';
import 'sequential_build.dart';

class ContainerOptions {
  final List<ContainerType> types;
  final List<ModuleDestination> moduleDestinations;
  final List<CurrentLocation> currentLocations;
  final List<SequentialBuild> sequentialBuilds = SequentialBuild.values;

  ContainerOptions(this.types, this.moduleDestinations, this.currentLocations);
}
