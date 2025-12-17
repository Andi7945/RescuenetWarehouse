import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/features/worklog/providers/work_log_providers.dart';

part 'work_logs_by_user_notifier.g.dart';

/// Watches work logs for a specific user.
/// Only rebuilds when logs for THIS user change.
///
/// Usage:
/// ```dart
/// final userLogs = ref.watch(workLogsByUserProvider(userId));
/// ```
@riverpod
class WorkLogsByUser extends _$WorkLogsByUser {
  @override
  Stream<List<LogEntry>> build(String userId) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByUser(userId);
  }
}
