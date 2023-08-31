import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/module_destination.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';

import 'container_dao.dart';
import 'container_type.dart';

import 'package:equatable/equatable.dart';

class RescueContainer extends Equatable {
  String id;
  int number;
  String name;
  String? description;
  ContainerType? type;
  SequentialBuild sequentialBuild;
  ModuleDestination? moduleDestination;
  CurrentLocation? currentLocation;
  bool isReady;
  bool toDeploy;

  String get printName => "$number: $name";

  RescueContainer(
      this.id,
      this.number,
      this.name,
      this.description,
      this.type,
      this.sequentialBuild,
      this.moduleDestination,
      this.currentLocation,
      this.isReady,
      this.toDeploy);

  RescueContainer.from({
    required RescueContainer container,
    String? name,
    int? number,
    String? description,
    ContainerType? type,
    SequentialBuild? sequentialBuild,
    ModuleDestination? moduleDestination,
    CurrentLocation? currentLocation,
    bool? isReady,
    bool? toDeploy,
  })  : id = container.id,
        number = number ?? container.number,
        name = name ?? container.name,
        description = description ?? container.description,
        type = type ?? container.type,
        sequentialBuild = sequentialBuild ?? container.sequentialBuild,
        moduleDestination = moduleDestination ?? container.moduleDestination,
        currentLocation = currentLocation ?? container.currentLocation,
        isReady = isReady ?? container.isReady,
        toDeploy = toDeploy ?? container.toDeploy;

  RescueContainer.fromDao(
      ContainerDao dao, this.type, this.moduleDestination, this.currentLocation)
      : id = dao.id,
        number = dao.number,
        description = dao.description,
        name = dao.name,
        sequentialBuild = dao.sequentialBuild,
        isReady = dao.isReady,
        toDeploy = dao.toDeploy;

  @override
  List<Object?> get props => [
        id,
        number,
        name,
        description,
        type,
        sequentialBuild,
        moduleDestination,
        currentLocation,
        isReady,
        toDeploy
      ];
}
