import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'assignment_by_id_notifier.g.dart';

/// Watches a single assignment by ID.
/// Only rebuilds when THIS specific assignment changes.
///
/// Usage:
/// ```dart
/// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
/// ```
@riverpod
class AssignmentById extends _$AssignmentById {
  @override
  Stream<Assignment?> build(String assignmentId) {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignment(assignmentId);
  }
}
