import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/module_destination.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';

import 'container_dao.dart';
import 'container_type.dart';

import 'package:equatable/equatable.dart';

class RescueContainer extends Equatable {
  double id;
  String name;
  ContainerType? type;
  String? imagePath;
  SequentialBuild sequentialBuild;
  ModuleDestination? moduleDestination;
  CurrentLocation? currentLocation;
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
    ModuleDestination? moduleDestination,
    CurrentLocation? currentLocation,
    bool? isReady,
    bool? toDeploy,
  })  : id = container.id,
        name = name ?? container.name,
        type = type ?? container.type,
        imagePath = imagePath ?? container.imagePath,
        sequentialBuild = sequentialBuild ?? container.sequentialBuild,
        moduleDestination = moduleDestination ?? container.moduleDestination,
        currentLocation = currentLocation ?? container.currentLocation,
        isReady = isReady ?? container.isReady,
        toDeploy = toDeploy ?? container.toDeploy;

  RescueContainer.fromDao(
      ContainerDao dao, this.type, this.moduleDestination, this.currentLocation)
      : id = dao.id,
        name = dao.name,
        imagePath = dao.imagePath,
        sequentialBuild = dao.sequentialBuild,
        isReady = dao.isReady,
        toDeploy = dao.toDeploy;

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
