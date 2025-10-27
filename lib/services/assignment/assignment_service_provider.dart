import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/repositories/auth_providers.dart';
import 'package:rescuenet_warehouse/services/assignment/assignment_service.dart';

part 'assignment_service_provider.g.dart';

@riverpod
AssignmentService assignmentService(AssignmentServiceRef ref) {
  return AssignmentService(
    assignmentRepository: ref.watch(assignmentRepositoryProvider),
    workLogRepository: ref.watch(workLogRepositoryProvider),
    currentUser: ref.watch(currentUserNameProvider) ?? 'Unknown',
  );
}
