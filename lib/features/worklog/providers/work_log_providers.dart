import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/features/worklog/repository/work_log_repository.dart';
import 'package:rescuenet_warehouse/features/worklog/repository/firebase_work_log_repository.dart';
import 'package:rescuenet_warehouse/features/worklog/repository/mock_work_log_repository.dart';

part 'work_log_providers.g.dart';

/// Provider for WorkLogRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
///
/// This is the single source of truth for work log repository dependency injection.
/// All work log notifiers and services should depend on this provider.
///
/// Can switch between Firebase (production) and Mock (testing) implementations
/// using the USE_MOCK_REPOSITORIES environment variable.
@riverpod
WorkLogRepository workLogRepository(WorkLogRepositoryRef ref) {
  // Check if we should use mock (for testing)
  const shouldUseMock = bool.fromEnvironment('USE_MOCK_REPOSITORIES', defaultValue: false);

  if (shouldUseMock) {
    return MockWorkLogRepository();
  } else {
    return FirebaseWorkLogRepository();
  }
}
