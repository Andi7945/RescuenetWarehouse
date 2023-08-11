import 'package:equatable/equatable.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'sequential_build.dart';

class ContainerDao extends Equatable {
  String id;
  String name;
  String? typeId;
  String? imagePath;
  SequentialBuild sequentialBuild;
  String? moduleDestination;
  String? currentLocation;
  bool isReady;
  bool toDeploy;

  ContainerDao(
      this.id,
      this.name,
      this.typeId,
      this.imagePath,
      this.sequentialBuild,
      this.moduleDestination,
      this.currentLocation,
      this.isReady,
      this.toDeploy);

  ContainerDao.fromContainer(RescueContainer container)
      : id = container.id,
        name = container.name,
        typeId = container.type.id,
        imagePath = container.imagePath,
        sequentialBuild = container.sequentialBuild,
        moduleDestination = container.moduleDestination,
        currentLocation = container.currentLocation,
        isReady = container.isReady,
        toDeploy = container.toDeploy;

  @override
  List<Object?> get props => [
        id,
        name,
        typeId,
        imagePath,
        sequentialBuild,
        moduleDestination,
        currentLocation,
        isReady,
        toDeploy
      ];
}
