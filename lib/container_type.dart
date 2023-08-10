import 'package:equatable/equatable.dart';

class ContainerType extends Equatable {
  String id;
  String name;
  double emptyWeight;
  String measurements;

  ContainerType(this.id, this.name, this.emptyWeight, this.measurements);

  @override
  List<Object> get props => [id, name, emptyWeight, measurements];

  ContainerType.from(
      {required ContainerType type,
      String? id,
      String? name,
      double? emptyWeight,
      String? measurements})
      : id = id ?? type.id,
        name = name ?? type.name,
        emptyWeight = emptyWeight ?? type.emptyWeight,
        measurements = measurements ?? type.measurements;
}
