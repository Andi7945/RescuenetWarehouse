import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'container_type.g.dart';

@JsonSerializable()
class ContainerType extends Equatable {
  String id;
  String name;
  String? imagePath;
  double emptyWeight;
  String measurements;

  ContainerType(
      this.id, this.name, this.imagePath, this.emptyWeight, this.measurements);

  @override
  List<Object?> get props => [id, name, imagePath, emptyWeight, measurements];

  ContainerType.from(
      {required ContainerType type,
      String? id,
      String? name,
      String? imagePath,
      double? emptyWeight,
      String? measurements})
      : id = id ?? type.id,
        name = name ?? type.name,
        imagePath = imagePath ?? type.imagePath,
        emptyWeight = emptyWeight ?? type.emptyWeight,
        measurements = measurements ?? type.measurements;

  factory ContainerType.fromJson(Map<String, dynamic> json) =>
      _$ContainerTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerTypeToJson(this);

  factory ContainerType.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ContainerType.fromJson(data ?? {});
  }

  Map<String, dynamic> toFirestore() => toJson();
}
