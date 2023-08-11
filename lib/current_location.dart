import 'package:equatable/equatable.dart';

class CurrentLocation extends Equatable {
  final String id;
  String name;

  CurrentLocation(this.id, this.name);

  @override
  List<Object> get props => [id, name];
}
