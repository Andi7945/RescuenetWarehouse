import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'work_logs_by_container_notifier.g.dart';

/// Watches work logs for a specific container.
/// Only rebuilds when logs for THIS container change.
///
/// Useful for container history/audit trail.
///
/// Usage:
/// ```dart
/// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
/// ```
@riverpod
class WorkLogsByContainer extends _$WorkLogsByContainer {
  @override
  Stream<List<LogEntry>> build(String containerId) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByContainer(containerId);
  }
}
