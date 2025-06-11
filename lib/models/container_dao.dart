import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import 'sequential_build.dart';

part 'container_dao.freezed.dart';
part 'container_dao.g.dart';

@freezed
abstract class ContainerDao with _$ContainerDao {
  const factory ContainerDao(
      {required String id,
      required int number,
      required String name,
      String? description,
      String? typeId,
      required SequentialBuild sequentialBuild,
      String? moduleDestinationId,
      String? currentLocationId,
      required bool isReady,
      required bool toDeploy}) = _ContainerDao;

  factory ContainerDao.fromContainer(RescueContainer container) => ContainerDao(
      id: container.id,
      number: container.number,
      name: container.name,
      description: container.description,
      typeId: container.type?.id,
      sequentialBuild: container.sequentialBuild,
      moduleDestinationId: container.moduleDestination?.id,
      currentLocationId: container.currentLocation?.id,
      isReady: container.isReady,
      toDeploy: container.toDeploy);

  factory ContainerDao.fromJson(Map<String, Object?> json) =>
      _$ContainerDaoFromJson(json);
}
