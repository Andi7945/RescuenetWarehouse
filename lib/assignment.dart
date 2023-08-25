import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'assignment.g.dart';

@JsonSerializable()
class Assignment implements FirebaseStorable<Assignment> {
  String id;
  String itemId;
  double containerId;
  int count;

  Assignment(this.id, this.itemId, this.containerId, this.count);

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentToJson(this);

  @override
  Assignment fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Assignment.fromJson(data ?? {});
  }

  @override
  Map<String, dynamic> toFirestore() => toJson();


}
