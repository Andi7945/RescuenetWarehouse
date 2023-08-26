import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'module_destination.g.dart';

@JsonSerializable()
class ModuleDestination extends Equatable
    implements FirebaseStorable<ModuleDestination> {
  @override
  final String id;
  String name;

  ModuleDestination(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory ModuleDestination.fromJson(Map<String, dynamic> json) =>
      _$ModuleDestinationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ModuleDestinationToJson(this);
}
