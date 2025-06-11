import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
abstract class Assignment with _$Assignment {
  const factory Assignment(
      {required String id,
      required String itemId,
      required String containerId,
      required int count}) = _Assignment;

  factory Assignment.fromJson(Map<String, Object?> json) =>
      _$AssignmentFromJson(json);
}
