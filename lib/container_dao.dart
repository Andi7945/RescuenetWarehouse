import 'package:equatable/equatable.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'sequential_build.dart';

class ContainerDao extends Equatable {
  double id;
  int number;
  String name;
  String? description;
  String? typeId;
  SequentialBuild sequentialBuild;
  String? moduleDestinationId;
  String? currentLocationId;
  bool isReady;
  bool toDeploy;

  ContainerDao(
      this.id,
      this.number,
      this.name,
      this.description,
      this.typeId,
      this.sequentialBuild,
      this.moduleDestinationId,
      this.currentLocationId,
      this.isReady,
      this.toDeploy);

  ContainerDao.fromContainer(RescueContainer container)
      : id = container.id,
        number = container.number,
        name = container.name,
        description = container.description,
        typeId = container.type?.id,
        sequentialBuild = container.sequentialBuild,
        moduleDestinationId = container.moduleDestination?.id,
        currentLocationId = container.currentLocation?.id,
        isReady = container.isReady,
        toDeploy = container.toDeploy;

  @override
  List<Object?> get props => [
        id,
        number,
        name,
        description,
        typeId,
        sequentialBuild,
        moduleDestinationId,
        currentLocationId,
        isReady,
        toDeploy
      ];
}
