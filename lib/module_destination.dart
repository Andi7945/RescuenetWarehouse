import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'module_destination.g.dart';

@JsonSerializable()
class ModuleDestination extends Equatable
    implements FirebaseStorable<ModuleDestination> {
  final String id;
  String name;

  ModuleDestination(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory ModuleDestination.fromJson(Map<String, dynamic> json) =>
      _$ModuleDestinationFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleDestinationToJson(this);

  @override
  ModuleDestination fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ModuleDestination.fromJson(data ?? {});
  }

  @override
  Map<String, dynamic> toFirestore() => toJson();
}
