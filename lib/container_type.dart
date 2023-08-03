import 'package:equatable/equatable.dart';

class ContainerType extends Equatable {
  String name;
  double emptyWeight;
  String measurements;

  ContainerType(this.name, this.emptyWeight, this.measurements);

  @override
  List<Object> get props => [name, emptyWeight, measurements];

  ContainerType.from(
      {required ContainerType type,
      String? name,
      double? emptyWeight,
      String? measurements})
      : name = name ?? type.name,
        emptyWeight = emptyWeight ?? type.emptyWeight,
        measurements = measurements ?? type.measurements;
}
