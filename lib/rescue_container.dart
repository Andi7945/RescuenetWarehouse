import 'package:rescuenet_warehouse/sequential_build.dart';

import 'container_type.dart';

import 'package:equatable/equatable.dart';

class RescueContainer extends Equatable {
  String id;
  String? name;
  ContainerType type;
  String? imagePath;
  SequentialBuild sequentialBuild;
  String? moduleDestination;
  String? currentLocation;
  bool isReady;
  bool toDeploy;

  RescueContainer(
      this.id,
      this.name,
      this.type,
      this.imagePath,
      this.sequentialBuild,
      this.moduleDestination,
      this.currentLocation,
      this.isReady,
      this.toDeploy);

  RescueContainer.from({
    required RescueContainer container,
    String? name,
    ContainerType? type,
    String? imagePath,
    SequentialBuild? sequentialBuild,
    String? moduleDestination,
    String? currentLocation,
    bool? isReady,
    bool? toDeploy,
  })  : this.id = container.id,
        this.name = name ?? container.name,
        this.type = type ?? container.type,
        this.imagePath = imagePath ?? container.imagePath,
        this.sequentialBuild = sequentialBuild ?? container.sequentialBuild,
        this.moduleDestination =
            moduleDestination ?? container.moduleDestination,
        this.currentLocation = currentLocation ?? container.currentLocation,
        this.isReady = isReady ?? container.isReady,
        this.toDeploy = toDeploy ?? container.toDeploy;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        imagePath,
        sequentialBuild,
        moduleDestination,
        currentLocation,
        isReady,
        toDeploy
      ];
}
