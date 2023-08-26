import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'current_location.g.dart';

@JsonSerializable()
class CurrentLocation extends Equatable implements FirebaseStorable<CurrentLocation> {
  @override
  final String id;
  String name;

  CurrentLocation(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      _$CurrentLocationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CurrentLocationToJson(this);
}
