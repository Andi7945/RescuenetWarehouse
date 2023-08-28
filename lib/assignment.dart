import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'assignment.g.dart';

@JsonSerializable()
class Assignment implements FirebaseStorable<Assignment> {
  @override
  String id;
  String itemId;
  String containerId;
  int count;

  Assignment(this.id, this.itemId, this.containerId, this.count);

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AssignmentToJson(this);

  Assignment copyWith(int count) => Assignment(id, itemId, containerId, count);
}
