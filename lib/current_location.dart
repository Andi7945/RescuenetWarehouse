import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'current_location.g.dart';

@JsonSerializable()
class CurrentLocation extends Equatable implements FirebaseStorable<CurrentLocation> {
  final String id;
  String name;

  CurrentLocation(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      _$CurrentLocationFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentLocationToJson(this);

  @override
  CurrentLocation fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return CurrentLocation.fromJson(data ?? {});
  }

  @override
  Map<String, dynamic> toFirestore() => toJson();


}
