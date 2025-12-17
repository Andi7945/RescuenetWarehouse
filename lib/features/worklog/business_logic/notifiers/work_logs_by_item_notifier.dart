import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/features/worklog/providers/work_log_providers.dart';

part 'work_logs_by_item_notifier.g.dart';

/// Watches work logs for a specific item.
/// Only rebuilds when logs for THIS item change.
///
/// Useful for item history/audit trail.
///
/// Usage:
/// ```dart
/// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
/// ```
@riverpod
class WorkLogsByItem extends _$WorkLogsByItem {
  @override
  Stream<List<LogEntry>> build(String itemId) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByItem(itemId);
  }
}
