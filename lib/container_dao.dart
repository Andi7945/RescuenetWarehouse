import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'sequential_build.dart';

part 'container_dao.g.dart';

@JsonSerializable()
class ContainerDao extends Equatable implements FirebaseStorable<ContainerDao> {
  String id;
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

  factory ContainerDao.fromJson(Map<String, dynamic> json) =>
      _$ContainerDaoFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerDaoToJson(this);

  @override
  ContainerDao fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ContainerDao.fromJson(data ?? {});
  }

  @override
  Map<String, dynamic> toFirestore() => toJson();
}
