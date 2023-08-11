import 'package:equatable/equatable.dart';

class ModuleDestination extends Equatable {
  final String id;
  String name;

  ModuleDestination(this.id, this.name);

  @override
  List<Object> get props => [id, name];
}
