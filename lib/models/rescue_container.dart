import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';

import 'container_dao.dart';
import 'container_type.dart';

part 'rescue_container.freezed.dart';

@freezed
class RescueContainer with _$RescueContainer {
  const RescueContainer._();

  const factory RescueContainer({
    required String id,
    required int number,
    required String name,
    String? description,
    ContainerType? type,
    required SequentialBuild sequentialBuild,
    ModuleDestination? moduleDestination,
    CurrentLocation? currentLocation,
    required bool isReady,
    required bool toDeploy,
  }) = _RescueContainer;

  String get printName => "$number: $name";

  factory RescueContainer.fromDao(
          ContainerDao dao,
          ContainerType? type,
          ModuleDestination? moduleDestination,
          CurrentLocation? currentLocation) =>
      RescueContainer(
          id: dao.id,
          type: type,
          moduleDestination: moduleDestination,
          currentLocation: currentLocation,
          number: dao.number,
          description: dao.description,
          name: dao.name,
          sequentialBuild: dao.sequentialBuild,
          isReady: dao.isReady,
          toDeploy: dao.toDeploy);
}
