import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/features/worklog/providers/work_log_providers.dart';

part 'work_logs_by_date_range_notifier.g.dart';

/// Watches work logs within a specific date range.
/// Only rebuilds when logs within THIS range change.
///
/// Useful for daily/weekly audit reports.
///
/// Usage:
/// ```dart
/// final todayLogs = ref.watch(workLogsByDateRangeProvider(
///   DateTime.now(),
///   DateTime.now().add(Duration(days: 1)),
/// ));
/// ```
@riverpod
class WorkLogsByDateRange extends _$WorkLogsByDateRange {
  @override
  Stream<List<LogEntry>> build(DateTime startDate, DateTime endDate) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByDateRange(startDate, endDate);
  }

  /// Get count of logs in this date range
  int get count => state.valueOrNull?.length ?? 0;
}
