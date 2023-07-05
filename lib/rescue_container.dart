import 'package:rescuenet_warehouse/sequential_build.dart';

import 'container_type.dart';

class RescueContainer {
  String id;
  String? name;
  ContainerType type;
  String? imagePath;
  SequentialBuild sequentialBuild;
  String? moduleDestination;
  String? currentLocation;

  RescueContainer(this.id, this.name, this.type, this.imagePath,
      this.sequentialBuild, this.moduleDestination, this.currentLocation);
}
