import 'package:equatable/equatable.dart';

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
}
