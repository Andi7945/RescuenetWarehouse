import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
class Assignment with _$Assignment implements FirebaseStorable<Assignment> {
  const factory Assignment(
      {required String id,
      required String itemId,
      required String containerId,
      required int count}) = _Assignment;

  factory Assignment.fromJson(Map<String, Object?> json) =>
      _$AssignmentFromJson(json);
}
